# ORD-371: package the tea-time special. Replace each ??? (three TODOs).

# TODO 1: start from the slim Python 3.12 image
FROM ???

# Make /app the working folder inside the container.
WORKDIR /app
# Copy only the dependency list first, so Docker can cache the install step.
COPY requirements.txt .

# TODO 2: install the requirements, without keeping pip's download cache
RUN ???

# Copy the rest of the project in.
COPY . .

# TODO 3: start the app with: flask --app app run   (on port 8001)
CMD ???
