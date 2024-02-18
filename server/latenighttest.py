from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route('/submit', methods=['POST'])
def submit():
    data = request.get_json()

    new_data = {
        "1": "Plug in the air fryer and preheat it to the recommended temperature.",
        "2": "Add your food into the basket, making sure not to overcrowd it.",
        "3": "Set the time and temperature according to the recipe, then press start to begin cooking.",
        "model": "tree"
    }
    return jsonify(new_data)


if __name__ == '__main__':
    app.run(debug=True, port=3000, host='0.0.0.0')
