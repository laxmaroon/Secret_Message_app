# encryption_decryption.py

from cryptography.fernet import Fernet

# Generate and save a key (only do this once and save the key securely)
def generate_key():
    key = Fernet.generate_key()
    with open("secret.key", "wb") as key_file:
        key_file.write(key)

# Load the key from a file
def load_key():
    return open("secret.key", "rb").read()

# Encrypt the audio file
def encrypt_file(input_file, output_file):
    key = load_key()
    fernet = Fernet(key)
    
    with open(input_file, "rb") as file:
        original = file.read()
        
    encrypted = fernet.encrypt(original)
    
    with open(output_file, "wb") as encrypted_file:
        encrypted_file.write(encrypted)

# Decrypt the audio file
def decrypt_file(encrypted_file, output_file):
    key = load_key()
    fernet = Fernet(key)
    
    with open(encrypted_file, "rb") as file:
        encrypted = file.read()
        
    decrypted = fernet.decrypt(encrypted)
    
    with open(output_file, "wb") as decrypted_file:
        decrypted_file.write(decrypted)

if __name__ == "__main__":
    # Example usage
    generate_key()  # Run this only once to generate the key
    encrypt_file("example.wav", "encrypted_example.wav")
    decrypt_file("encrypted_example.wav", "decrypted_example.wav")
