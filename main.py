from asyncio import sleep
from flask import Flask, request, jsonify
import ollama

app = Flask(__name__)

@app.route('/chat', methods=['POST'])
def chat():
    messages = request.json.get('messages')
    if not messages:
        return jsonify({'error': 'No messages provided'}), 400

    try:
        stream = ollama.chat(messages, model='deepseek-r1:1.5b', host='127.0.0.1')
        response = [message for message in stream]
        return jsonify({'response': response}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(host='localhost', port=8000, debug=True)

