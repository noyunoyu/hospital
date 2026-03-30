import json

from flask import Flask, jsonify, request
from flask_cors import CORS
# 导入SQLAlchemy（ORM工具，简化数据库操作）
from flask_sqlalchemy import SQLAlchemy
# 解决MySQL连接编码问题
import pymysql

pymysql.install_as_MySQLdb()

app = Flask(__name__)
CORS(app)  # 跨域配置（保留）

# ---------------- MySQL数据库配置 ----------------
# 格式：mysql://用户名:密码@主机:端口/数据库名?编码
app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql://root:zlt56688658@localhost:3306/hospital'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False  # 关闭不必要的警告
app.config['SQLALCHEMY_ECHO'] = True  # 打印SQL语句（开发阶段方便调试）

# 初始化ORM对象
db = SQLAlchemy(app)


# ---------------- 定义数据模型（对应MySQL表） ----------------
# 模型名：DataModel → 数据库表名：data_model（自动小写+下划线）
class DataModel(db.Model):
    # 主键ID（自增）
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    # 标题（非空，字符串类型）
    title = db.Column(db.String(100), nullable=False)
    # 内容（非空，字符串类型）
    content = db.Column(db.String(500), nullable=False)
    # 列表数据（存储JSON字符串，适配前端list数组）
    list_data = db.Column(db.Text, nullable=False, default='[]')

    # 转JSON方法（方便接口返回）
    def to_dict(self):
        return {
            "id": self.id,
            "title": self.title,
            "content": self.content,
            "list": eval(self.list_data)  # 把JSON字符串转回数组
        }


# ---------------- 初始化数据库（首次运行执行） ----------------
with app.app_context():
    # 创建所有表（如果表不存在）
    db.create_all()
    # 初始化测试数据（仅首次运行添加）
    if not DataModel.query.first():
        test_data = DataModel(
            title="鸿蒙前端初始标题",
            content="这是来自MySQL数据库的内容",
            list_data='["数据库数据1", "数据库数据2", "数据库数据3"]'
        )
        db.session.add(test_data)
        db.session.commit()


# ---------------- 原有接口改造（从MySQL取数据） ----------------
@app.route('/api/get_data', methods=['GET'])
def get_data():
    # 从MySQL查询第一条数据
    data = DataModel.query.first()
    if data:
        return jsonify(
            code=200,
            msg="success",
            data=data.to_dict()  # 转JSON返回
        )
    else:
        return jsonify(
            code=404,
            msg="暂无数据",
            data={"title": "", "content": "", "list": []}
        )


# ---------------- 新增POST接口（向MySQL存数据） ----------------
# 前端可调用此接口提交数据，UI无需改动，仅新增调用逻辑即可
@app.route('/api/submit_data', methods=['POST'])
def submit_data():
    req_data = request.get_json()
    if not req_data or not req_data.get("title"):
        return jsonify(code=400, msg="标题不能为空")

    # 新增数据到MySQL
    new_data = DataModel(
        title=req_data["title"],
        content=req_data.get("content", ""),
        list_data=json.dumps(req_data.get("list", []))  # 数组转JSON字符串存储
    )
    db.session.add(new_data)
    db.session.commit()

    return jsonify(code=200, msg="数据提交成功", data=new_data.to_dict())


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)