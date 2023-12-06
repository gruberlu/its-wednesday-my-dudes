#!/bin/bash

# Check if OPENAI_API_KEY is set
if [[ -z "$OPENAI_API_KEY" ]]; then
  echo "Environment variable OPENAI_API_KEY is not set."
  exit 1
fi

# Read prompt
if [[ -z "$OPENAI_PROMPT" ]]; then
  echo -n "Prompt: "
  read OPENAI_PROMPT
fi

# API endpoint
OPENAI_API_URL="https://api.openai.com/v1/images/generations"

RESPONSE=$(
    curl "$OPENAI_API_URL" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $OPENAI_API_KEY" \
        -d "{
            \"model\": \"dall-e-3\",
            \"prompt\": \"$OPENAI_PROMPT\",
            \"n\": 1,
            \"size\": \"1024x1024\"
        }" \
  )

URL=$(echo "$RESPONSE" | jq .data[0].url -r)
REVISED_PROMPT=$(echo "$RESPONSE" | jq .data[0].revised_prompt -r)

curl "$URL" -o "src/assets/$(date "+%s").png"
echo "{\"text\": \"$REVISED_PROMPT\"}" > "src/assets/$(date "+%s").json"

# Check if curl was successful
if [ $? -eq 0 ]; then
  echo "Image generated and saved successfully!"
else
  echo "Error generating and saving image."
fi
