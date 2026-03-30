from flask import Flask, jsonify, request
from flask_cors import CORS
import pymysql
from datetime import datetime, timedelta  # 新增导入timedelta

# 初始化Flask应用
app = Flask(__name__)
# 解决跨域（允许前端调用）
CORS(app)

# ========== 配置你的MySQL数据库信息（已填写） ==========
DB_CONFIG = {
    "host": "localhost",  # 数据库地址（本地填localhost）
    "user": "root",  # 数据库用户名（默认root）
    "password": "zlt56688658",  # 密码
    "database": "hospital",  # 数据库名
    "charset": "utf8mb4"  # 编码（避免中文乱码）
}


def format_department(department):
    """
    格式化科室名称：只保留"-"之前的部分
    例如："消化内科-门诊3楼东区501" -> "消化内科"
    """
    if not department:
        return ""
    # 按 "-" 分割，取第一部分
    return department.split('-')[0].strip()


# 封装数据库连接函数
def get_db_connection():
    """创建并返回MySQL数据库连接"""
    conn = pymysql.connect(**DB_CONFIG)
    # 设置游标为字典格式（方便获取字段名）
    cursor = conn.cursor(pymysql.cursors.DictCursor)
    return conn, cursor


# ========== 时间格式化工具（支持多种格式） ==========
def format_datetime(value, fmt="default"):
    """
    灵活时间格式化：不同页面用不同格式，互不影响
    fmt="default"    → 2025年03月27日 周四 上午（列表页用）
    fmt="detail"     → 2025/03/27 09:00:00（详情页用）
    fmt="simple"     → 2025-03-27（简洁版）
    """
    if value is None or not isinstance(value, datetime):
        return ""

    if fmt == "detail":
        # 详情页格式：2025/03/27 09:00:00
        return value.strftime('%Y/%m/%d %H:%M:%S')
    elif fmt == "simple":
        return value.strftime('%Y-%m-%d %H:%M')
    else:
        # 默认格式（列表页）：2025年03月27日 周四 上午
        week_days = ["周一", "周二", "周三", "周四", "周五", "周六", "周日"]
        week_day = week_days[value.weekday()]
        period = "上午" if value.hour < 12 else "下午"
        return f"{value.strftime('%Y年%m月%d日')} {week_day} {period}"


# ========== 新增：时间类型安全转换函数（核心修复） ==========
def safe_serialize(value):
    """
    安全序列化函数：将datetime/timedelta/None等类型转为前端可识别的字符串
    """
    if value is None:
        return ""
    elif isinstance(value, datetime):
        week_days = ["周一", "周二", "周三", "周四", "周五", "周六", "周日"]
        week_day = week_days[value.weekday()]
        period = "上午" if value.hour < 12 else "下午"
        return f"{value.strftime('%Y年%m月%d日')} {week_day} {period}"
    elif isinstance(value, timedelta):
        total_seconds = int(value.total_seconds())
        hours = total_seconds // 3600
        minutes = (total_seconds % 3600) // 60
        return f"{hours}:{minutes:02d}"
    else:
        return str(value)


def format_status(status):
    """将数据库中的状态统一转换为前端展示文本"""
    if status is None:
        return ""

    # 如果数据库存的是数字
    if str(status) == "0":
        return "预约成功"
    elif str(status) == "1":
        return "已完成"
    elif str(status) == "2":
        return "已取消"


# ========== 接口：根据ID获取预约详情（已修复序列化问题） ==========
@app.route('/api/appointment/<int:appointment_id>', methods=['GET'])
def get_appointment_detail(appointment_id):
    try:
        # 连接数据库
        conn, cursor = get_db_connection()

        # 查询预约表（参数化查询防SQL注入）
        sql = """
            SELECT * FROM appointment_registration 
            WHERE id = %s
        """
        cursor.execute(sql, (appointment_id,))
        record = cursor.fetchone()

        # 关闭连接
        cursor.close()
        conn.close()

        # 无数据返回404
        if not record:
            return jsonify({
                "code": 404,
                "msg": "未找到该预约记录"
            }), 404

        # 格式化数据（适配前端页面的变量名和展示格式，已加安全序列化）
        formatted_data = {
            "doctorName": record.get("doctor_name", ""),  # 医生姓名
            "doctorTitle": record.get("doctor_title", ""),  # 医生职称
            "hospital": record.get("hospital_name", ""),  # 就诊医院
            "address": record.get("hospital_address", ""),  # 医院地址
            "department": record.get("department", ""),  # 就诊科室（保持完整）
            "clinicTime": safe_serialize(record.get("clinic_time", "")),  # 门诊时间（修复序列化）
            "waitTime": safe_serialize(record.get("waiting_time", "")),  # 候诊时间（修复序列化）
            "fee": f"¥{float(safe_serialize(record.get('fee', 0)))}",  # 费用（兼容数字转字符串）
            "appointmentTime": safe_serialize(record.get("appointment_time", "")),  # 预约时间（修复序列化）
            "patientName": record.get("patient_name", ""),  # 就诊人姓名
            "idCard": record.get("patient_id_card", ""),  # 身份证号
            "status": safe_serialize(record.get("status"))  # 预约状态（兼容数字/字符串状态）
        }

        # 返回给前端的数据（和前端类型完全匹配）
        return jsonify({
            "code": 200,
            "msg": "success",
            "data": formatted_data
        })

    except Exception as e:
        # 异常捕获（方便调试）
        return jsonify({
            "code": 500,
            "msg": f"查询失败：{str(e)}"
        }), 500


# =============== 根据就诊人或时间筛选预约信息 ==========
@app.route('/api/appointments', methods=['GET'])
def get_appointment_list():
    try:
        patient_id_card = request.args.get('patient_id_card', '').strip()
        time_range = request.args.get('time_range', '1year').strip()

        conn, cursor = get_db_connection()

        sql = """
            SELECT id, doctor_name, department, hospital_address, clinic_time,
                   patient_name, patient_id_card, status
            FROM appointment_registration
            WHERE 1=1
        """
        params = []

        # 按就诊人筛选
        if patient_id_card:
            sql += " AND patient_id_card = %s"
            params.append(patient_id_card)

        # 按时间范围筛选
        now = datetime.now()
        if time_range == "3months":
            start_time = now - timedelta(days=90)
            sql += " AND clinic_time >= %s"
            params.append(start_time)
        elif time_range == "6months":
            start_time = now - timedelta(days=180)
            sql += " AND clinic_time >= %s"
            params.append(start_time)
        elif time_range == "1year":
            start_time = now - timedelta(days=365)
            sql += " AND clinic_time >= %s"
            params.append(start_time)
        elif time_range == "all":
            pass

        sql += " ORDER BY clinic_time DESC"

        cursor.execute(sql, params)
        records = cursor.fetchall()

        cursor.close()
        conn.close()

        data = []
        for record in records:
            # 获取完整科室名
            department_full = record.get('department', '')
            # 提取短科室名（用于标题）
            department_short = format_department(department_full)

            data.append({
                "id": record.get("id"),
                "title": f"{department_short} {record.get('doctor_name', '')}",  # 标题用短科室名
                "status": format_status(record.get("status")),
                "department": department_full,  # 保留完整科室名
                "time": safe_serialize(record.get("clinic_time")),
                "patient": record.get("patient_name", "")
            })


        return jsonify({
            "code": 200,
            "msg": "success",
            "data": data
        })

    except Exception as e:
        return jsonify({
            "code": 500,
            "msg": f"查询失败：{str(e)}",
            "data": []
        }), 500


# =============== 根据就诊人筛选预约信息 ==========
@app.route('/api/patients', methods=['GET'])
def get_patients():
    """获取所有就诊人列表（实际可根据登录用户筛选，这里简化返回全部）"""
    try:
        conn, cursor = get_db_connection()
        sql = "SELECT id, name, relation, id_number, is_default ,card_number FROM patient ORDER BY is_default DESC, id ASC"
        cursor.execute(sql)
        records = cursor.fetchall()
        cursor.close()
        conn.close()

        # 格式化返回数据
        patients = []
        for record in records:
            patients.append({
                "id": record["id"],
                "name": record["name"],
                "relation": record["relation"],          # 关系（本人/父母等）
                "idNumber": record["id_number"],         # 完整身份证号
                "isDefault": record["is_default"]  ,
                "cardNumber":record.get("card_number","")# 是否默认就诊人
            })

        return jsonify({
            "code": 200,
            "msg": "success",
            "data": patients
        })
    except Exception as e:
        return jsonify({
            "code": 500,
            "msg": f"查询就诊人失败：{str(e)}",
            "data": []
        }), 500

# ============== 缴费相关接口 ============
@app.route('/api/payments', methods=['GET'])
def get_payment_list():
    """获取缴费订单列表（按订单号分组）"""
    try:
        medical_card_no = request.args.get('medical_card_no', '').strip()
        time_range = request.args.get('time_range', '1year').strip()

        conn, cursor = get_db_connection()

        sql = """
            SELECT 
                order_no, 
                MAX(fee_type) AS fee_type,
                MAX(department) AS department,
                MAX(doctor_name) AS doctor_name,
                MAX(patient_name) AS patient_name,
                MAX(medical_card_no) AS medical_card_no,
                MAX(payment_method) AS payment_method,
                MAX(card_balance) AS card_balance,
                MAX(order_total) AS order_total,
                MAX(order_time) AS order_time,
                COUNT(*) AS drug_count
            FROM outpatient_payment
            WHERE 1=1
        """
        params = []

        if medical_card_no:
            sql += " AND medical_card_no = %s"
            params.append(medical_card_no)

        # 时间筛选
        now = datetime.now()
        if time_range == "3months":
            start_time = now - timedelta(days=90)
            sql += " AND order_time >= %s"
            params.append(start_time)
        elif time_range == "6months":
            start_time = now - timedelta(days=180)
            sql += " AND order_time >= %s"
            params.append(start_time)
        elif time_range == "1year":
            start_time = now - timedelta(days=365)
            sql += " AND order_time >= %s"
            params.append(start_time)
        # 'all' 不添加时间条件

        sql += " GROUP BY order_no ORDER BY order_time DESC"

        cursor.execute(sql, params)
        records = cursor.fetchall()
        cursor.close()
        conn.close()

        data = []
        for rec in records:
            data.append({
                "orderNo": rec["order_no"],
                "feeType": rec["fee_type"],
                "department": rec["department"],
                "doctorName": rec["doctor_name"],
                "patientName": rec["patient_name"],
                "medicalCardNo": rec["medical_card_no"],
                "paymentMethod": rec["payment_method"],
                "cardBalance": str(rec["card_balance"]),
                "orderTotal": str(rec["order_total"]),
                "orderTime": format_datetime(rec["order_time"],fmt="simple"),
                "drugCount": rec["drug_count"]
            })
            print("SQL:", sql, "Params:", params)

        return jsonify({
            "code": 200,
            "msg": "success",
            "data": data
        })
    except Exception as e:
        return jsonify({
            "code": 500,
            "msg": f"查询失败：{str(e)}",
            "data": []
        }), 500

# ============ 订单详情 ============
@app.route('/api/payment/<order_no>', methods=['GET'])
def get_payment_detail(order_no):
    """获取订单详情（包含所有药品明细）"""
    try:
        conn, cursor = get_db_connection()
        sql = """
            SELECT 
                id, fee_type, department, doctor_name, patient_name, medical_card_no,
                drug_name, unit_price, quantity, drug_total,
                payment_method, card_balance, order_total, order_no, order_time
            FROM outpatient_payment
            WHERE order_no = %s
            ORDER BY id
        """
        cursor.execute(sql, (order_no,))
        records = cursor.fetchall()
        cursor.close()
        conn.close()

        if not records:
            return jsonify({"code": 404, "msg": "未找到该订单"}), 404

        # 订单基本信息（取第一条）
        first = records[0]

        # 构建药品明细列表
        items = []
        for rec in records:
            items.append({
                "drugName": rec["drug_name"],
                "unitPrice": str(rec["unit_price"]),
                "quantity": rec["quantity"],
                "drugTotal": str(rec["drug_total"])
            })

        detail = {
            "orderNo": first["order_no"],
            "feeType": first["fee_type"],
            "department": first["department"],
            "doctorName": first["doctor_name"],
            "patientName": first["patient_name"],
            "medicalCardNo": first["medical_card_no"],
            "paymentMethod": first["payment_method"],
            "cardBalance": str(first["card_balance"]),
            "orderTotal": str(first["order_total"]),
            "orderTime": format_datetime(first["order_time"], fmt="detail"),
            "items": items
        }

        return jsonify({
            "code": 200,
            "msg": "success",
            "data": detail
        })
    except Exception as e:
        return jsonify({
            "code": 500,
            "msg": f"查询失败：{str(e)}"
        }), 500

# ========== 启动服务 ==========
if __name__ == '__main__':
    # host=0.0.0.0 允许局域网访问，port=5000（和之前一致）
    app.run(host="0.0.0.0", port=5000, debug=True)