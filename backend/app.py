from flask import Flask, request, jsonify
import joblib
from flask_cors import CORS

app = Flask(__name__)
CORS(app)
model = joblib.load("sales_model.pkl")

@app.route("/")
def home():
    return "Backend running in browser"

@app.route("/predict", methods=["POST"])
def predict():
    data = request.get_json()
    prediction = model.predict([[data["quantity"], data["price"]]])
    return jsonify({"predicted_sales": int(prediction[0])})

if __name__ == "__main__":
    app.run(debug=True)
