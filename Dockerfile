FROM python:3.11.0b1-buster

# set work directory
WORKDIR /app

# Update package repository and install necessary packages
RUN apt-get update && \
    apt-get install --no-install-recommends -y \
    dnsutils=1:9.11.5.P4+dfsg-5.1+deb10u9 \
    libpq-dev=11.16-0+deb10u1 \
    python3-dev=3.7.3-1 \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Install pip
RUN python -m pip install --no-cache-dir pip==22.0.4

# Copy and install project dependencies
COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy project files
COPY . /app/

# Expose port
EXPOSE 8000

# Run migrations and start the server
RUN python3 /app/manage.py migrate
WORKDIR /app/pygoat/
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "6", "pygoat.wsgi"]
