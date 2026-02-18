import pickle
import numpy as np
from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)   # allow Flutter web requests

#load trained model
model=pickle.load(open("sales_model.pkl","rb"))
# Home route (for testing)
@app.route("/")
def home():
    return "Backend is running"

#prediction route 
@app.route("/predict", methods=["POST"])
def predict():
    data = request.get_json()

    product = float(data.get("product"))
    quantity = float(data.get("quantity"))
    price = float(data.get("price"))

    #model expects 2D array
    features=np.array([[quantity,price]])
    prediction=model.predict(features)

    return jsonify({
        "prediction":round(float(prediction[0]),2)
    })

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
