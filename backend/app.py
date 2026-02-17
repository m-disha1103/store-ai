from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)   # allow Flutter web requests

@app.route("/")
def home():
    return "Backend is running"

@app.route("/predict", methods=["POST"])
def predict():
    print("Predict API called")

    data = request.get_json()
    quantity = data.get("quantity", 0)
    price = data.get("price", 0)

    prediction = quantity * price  # simple logic

    return jsonify({
        "prediction": prediction
    })

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
