import os
from flask import Flask

# Initialize the Flask application
app = Flask(__name__)

# Define the route for the home/root URL
@app.route('/')
def home():
    return 'DevOps Capstone v2 - pipeline is working!".'

@app.route('/health')
def health():
    return {"status": "healthy"}, 200

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0',port=port)

