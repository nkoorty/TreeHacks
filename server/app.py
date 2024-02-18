from flask import Flask, request, jsonify
from openai import OpenAI, OpenAIError
import subprocess
from dotenv import load_dotenv
import os

load_dotenv()

app = Flask(__name__)

openai_api_key = os.getenv("OPENAI_API_KEY")

openai_client = OpenAI(api_key=openai_api_key)

@app.route('/chat', methods=['POST'])



def chat():
    try:    
        data = request.json
        question = data.get('prompt', '')
        label = data.get('label', '')
        print(type(label))
        prompt = f"Write a tutorial on {question} ({label}) aimed at senior citizens who are complete beginners in the subject. Keep the tutorial only 3 lines long - extremely concise to cover only the basics. Ensure that each step is clear and easy to follow. Consider using simple language and providing visual aids where necessary to aid understanding. Your goal is to empower seniors to grasp the fundamental concepts without overwhelming them with technical jargon or advanced techniques. Format your tutorial steps in a JSON (JavaScript Object Notation) structure for clarity and organization."
        
        if not prompt:
            return jsonify({'error': 'Prompt not provided'}), 400

        response = openai_client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[{"role": "user", "content": prompt}]
)
        
        gptRaw = response.choices[0].message.content
        
        # Path to your shell script
        script_path = '/Users/adesh/Documents/treehacksGPT/t23d.sh'
        process = subprocess.Popen(script_path, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)

        # Input data into the 3D generative AI model
        input_data = label
        process.stdin.write(input_data)
        process.stdin.flush()  # buffer


        output, errors = process.communicate()


        print("Output:", output)

        return gptRaw
    
    except OpenAIError as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True, port=3000, host='0.0.0.0')



