import re
import time
import os
from deep_translator import GoogleTranslator

def chunk_text(text, max_length=3000):
    chunks = []
    paragraphs = text.split('\n')
    current_chunk = []
    current_length = 0
    
    for p in paragraphs:
        if current_length + len(p) < max_length:
            current_chunk.append(p)
            current_length += len(p) + 1
        else:
            chunks.append('\n'.join(current_chunk))
            current_chunk = [p]
            current_length = len(p) + 1
    if current_chunk:
        chunks.append('\n'.join(current_chunk))
    return chunks

def main():
    try:
        with open('/Users/martinliu/Documents/GitHub/dkd/Readme.md', 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception as e:
        print("Failed to read file:", e)
        return

    def image_replacer(match):
        alt_text = match.group(1)
        img_path = match.group(2)
        # Annotation placeholder
        return f'![{alt_text}]({img_path})\n> *Annotation: An image illustrating {alt_text or "the relevant interface/process"}*'

    content = re.sub(r'!\[(.*?)\]\((.*?)\)', image_replacer, content)
    content = re.sub(r'<img src="(.*?)" .*?/>', lambda m: m.group(0) + '\n> *Annotation: An image showing application details*', content)

    chunks = chunk_text(content, max_length=2000)
    translator = GoogleTranslator(source='zh-CN', target='en')

    print(f"Total chunks: {len(chunks)}")
    translated_chunks = []
    for i, chunk in enumerate(chunks):
        if not chunk.strip():
            translated_chunks.append("")
            continue
        print(f"Translating chunk {i+1}/{len(chunks)}...")
        try:
            translated = translator.translate(chunk)
            translated_chunks.append(translated)
        except Exception as e:
            print(f"Error on chunk {i+1}: {e}")
            try:
                # Retry once
                time.sleep(2)
                translated = translator.translate(chunk)
                translated_chunks.append(translated)
            except Exception as e2:
                print(f"Failed retry: {e2}")
                translated_chunks.append(f"[Translation Failed: {chunk}]")
        time.sleep(0.2)

    output_path = '/Users/martinliu/Documents/GitHub/dkd/README_EN.md'
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write('\n'.join(translated_chunks))
    print(f"Translation done. Saved to {output_path}")

if __name__ == "__main__":
    main()
