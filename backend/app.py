from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)   # allow Flutter web requests
# Home route (for testing)
@app.route("/")
def home():
    return "Backend is running"

#prediction route 
@app.route("/predict", methods=["POST"])
def predict():
    data = request.get_json()

    product = data.get("product")
    quantity = data.get("quantity")
    price = data.get("price")

    prediction = quantity * price  # simple logic

    return jsonify({
        "product": product,
        "prediction": prediction
    })

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
