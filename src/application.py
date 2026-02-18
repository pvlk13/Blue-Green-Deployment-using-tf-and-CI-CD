from flask import Flask

# Elastic Beanstalk looks for a variable named 'application' by default
application = Flask(__name__)

@application.route('/')
def hello_world():
    return '<h1>Success!</h1><p>Blue-Green Deployment is Working.</p>'

if __name__ == "__main__":
    # Setting debug to True can help with troubleshooting
    application.run(debug=True)