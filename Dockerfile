# Base image using Python 3.9 with Alpine Linux 3.13
FROM python:3.9-alpine3.13

# Label for informational purposes (optional)
LABEL maintainer="Marshal Olu"

# Enable unbuffered output (optional, might be useful for debugging)
ENV PYTHONUNBUFFERED 1

# Copy requirements.txt (alternative: multi-stage build for production)
COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt

# Copy application directory
COPY ./app /app

# Working directory for subsequent commands
WORKDIR /app

# Expose port for Django web application
EXPOSE 8000

# Create virtual environment (alternative: pre-build virtual environment image)
ARG DEV=false
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    apk add --update --no-cache postgresql-client && \
    apk add --upgrade --no-cache build-base postgresql-dev musl-dev && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ $DEV = "true" ]; then /py/bin/pip install -r /tmp/requirements.dev.txt ; fi && \
    /py/bin/pip install flake8 && \
    rm -rf /tmp && \
    apk del build-base postgresql-dev musl-dev && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user

# Set path to include virtual environment (if using virtual environment)
ENV PATH="/py/bin:$PATH"

# User to run the application (consider security implications)
USER django-user
