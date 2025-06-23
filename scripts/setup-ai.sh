#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print status messages
print_status() {
  echo -e "${GREEN}==>${NC} $1"
}

print_error() {
  echo -e "${RED}Error:${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}Warning:${NC} $1"
}

# Check if running on macOS
if [[[[[ "$(uname)" != "Darwin" ]]]]]; then
  print_error "This script is designed for macOS only"
  exit 1
fi

# Check if running as root
if [[[[[ $EUID -eq 0 ]]]]]; then
  print_error "This script should not be run as root"
  exit 1
fi

# Function to check GPU support
check_gpu() {
  print_status "Checking GPU support..."
  if [[[[[ -n "$(lspci | grep -i nvidia)" ]]]]]; then
    print_status "NVIDIA GPU detected"
    return 0
  else
    print_warning "No NVIDIA GPU detected. Some features may be limited."
    return 1
  fi
}

# Function to set up Python environment
setup_python_env() {
  print_status "Setting up Python environment..."

  # Create a new conda environment
  conda create -n ai-dev python=3.11 -y
  conda activate ai-dev

  # Install common AI packages
  pip install --upgrade pip
  pip install torch torchvision torchaudio
  pip install transformers
  pip install sentence-transformers
  pip install chromadb
  pip install qdrant-client
  pip install weaviate-client
  pip install langchain
  pip install llama-cpp-python
  pip install fastapi uvicorn
  pip install pydantic
  pip install pytest
  pip install black isort flake8 mypy
  pip install jupyter notebook
  pip install ipywidgets
  pip install tqdm
  pip install numpy pandas scipy scikit-learn
  pip install matplotlib seaborn
  pip install tensorboard
}

# Function to set up Ollama
setup_ollama() {
  print_status "Setting up Ollama..."

  # Start Ollama service
  ollama serve &

  # Pull common models
  print_status "Pulling common models (this may take a while)..."
  ollama pull llama2
  ollama pull mistral
  ollama pull codellama
  ollama pull neural-chat
}

# Function to set up vector databases
setup_vector_dbs() {
  print_status "Setting up vector databases..."

  # Create Docker Compose file for vector databases
  cat >docker-compose.yml <<'EOL'
version: '3.8'

services:
  chroma:
    image: chromadb/chroma
    ports:
      - "8000:8000"
    volumes:
      - chroma_data:/chroma/chroma

  qdrant:
    image: qdrant/qdrant
    ports:
      - "6333:6333"
      - "6334:6334"
    volumes:
      - qdrant_data:/qdrant/storage

  weaviate:
    image: semitechnologies/weaviate:1.24.1
    ports:
      - "8080:8080"
    environment:
      QUERY_DEFAULTS_LIMIT: 25
      AUTHENTICATION_ANONYMOUS_ACCESS_ENABLED: 'true'
      PERSISTENCE_DATA_PATH: '/var/lib/weaviate'
      DEFAULT_VECTORIZER_MODULE: 'none'
      CLUSTER_HOSTNAME: 'node1'
    volumes:
      - weaviate_data:/var/lib/weaviate

volumes:
  chroma_data:
  qdrant_data:
  weaviate_data:
EOL

  # Start vector databases
  docker-compose up -d
}

# Function to create example AI project
create_example_project() {
  print_status "Creating example AI project..."

  mkdir -p ~/ai-projects/example
  cd ~/ai-projects/example

  # Create requirements.txt
  cat >requirements.txt <<'EOL'
torch
transformers
sentence-transformers
chromadb
qdrant-client
weaviate-client
langchain
llama-cpp-python
fastapi
uvicorn
pydantic
EOL

  # Create example script
  cat >example.py <<'EOL'
from transformers import pipeline
from sentence_transformers import SentenceTransformer
import chromadb
from qdrant_client import QdrantClient
import weaviate

def main():
    # Example: Text generation with transformers
    generator = pipeline('text-generation', model='gpt2')
    result = generator('Hello, I am a', max_length=30, num_return_sequences=1)
    print("Generated text:", result[0]['generated_text'])

    # Example: Text embeddings with sentence-transformers
    model = SentenceTransformer('all-MiniLM-L6-v2')
    sentences = ["This is an example sentence", "Each sentence is converted"]
    embeddings = model.encode(sentences)
    print("Embeddings shape:", embeddings.shape)

    # Example: Vector database with Chroma
    client = chromadb.Client()
    collection = client.create_collection(name="my_collection")
    collection.add(
        documents=["This is a document", "This is another document"],
        metadatas=[{"source": "doc1"}, {"source": "doc2"}],
        ids=["1", "2"]
    )
    results = collection.query(
        query_texts=["This is a query"],
        n_results=2
    )
    print("Chroma results:", results)

if __name__ == "__main__":
    main()
EOL

  # Create README
  cat >README.md <<'EOL'
# AI Development Example

This is an example project demonstrating various AI tools and libraries.

## Setup

1. Create a conda environment:
   ```bash
   conda create -n ai-dev python=3.11
   conda activate ai-dev
   ```

2. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

3. Run the example:
   ```bash
   python example.py
   ```

## Features

- Text generation with transformers
- Text embeddings with sentence-transformers
- Vector database operations with Chroma
- Integration with Qdrant and Weaviate

## Tools

- Ollama for local LLM inference
- Chroma, Qdrant, and Weaviate for vector storage
- PyTorch for deep learning
- FastAPI for API development
EOL
}

# Main function
main() {
  print_status "Starting AI development environment setup..."

  # Check GPU support
  check_gpu

  # Set up Python environment
  setup_python_env

  # Set up Ollama
  setup_ollama

  # Set up vector databases
  setup_vector_dbs

  # Create example project
  create_example_project

  print_status "AI development environment setup completed!"
  print_status "Example project created at ~/ai-projects/example"
  print_status "To start using the environment:"
  print_status "1. Activate the conda environment: conda activate ai-dev"
  print_status "2. Navigate to the example project: cd ~/ai-projects/example"
  print_status "3. Run the example: python example.py"
}

# Run the main function
main
