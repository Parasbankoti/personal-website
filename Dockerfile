# Use the official Nginx lightweight image
FROM nginx:alpine

# Copy the static website files into the Nginx default serving directory
COPY . /usr/share/nginx/html

# Expose port 80 (the default Nginx port)
EXPOSE 80

# Nginx starts automatically, so no CMD is needed
