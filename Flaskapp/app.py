from flask import Flask

# Initialize the Flask application
app = Flask(__name__)

# Define the route for the home/root URL
@app.route('/')
def home():
    return 'Hello, Flask! Your web application is running.'

@app.route('/health')
def health():
    return {"status": "healthy"}, 200

if __name__ == '__main__':
    app.run(host='0.0.0.0',port=6000)

