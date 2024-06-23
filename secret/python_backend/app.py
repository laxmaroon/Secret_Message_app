from flask import Flask, request, send_file, jsonify
from enc_dec import encrypt_file, decrypt_file, generate_key, load_key

app = Flask(__name__)

@app.route("/encrypt", methods=["POST"])
def encrypt():
    input_file = request.files['file']
    input_file.save("temp_input.wav")
    key = generate_key()  # Generate a new key for each encryption
    encrypt_file("temp_input.wav", "temp_encrypted.wav", key)
    
    return jsonify({'key': key.decode('utf-8')}), send_file("temp_encrypted.wav", as_attachment=True)

@app.route("/decrypt", methods=["POST"])
def decrypt():
    encrypted_file = request.files['file']
    key = request.form['key']
    encrypted_file.save("temp_encrypted.wav")
    decrypt_file("temp_encrypted.wav", "temp_decrypted.wav", key.encode('utf-8'))
    return send_file("temp_decrypted.wav", as_attachment=True)

if __name__ == "__main__":
    app.run(debug=True)
