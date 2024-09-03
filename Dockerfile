FROM golang:1.23-bullseye AS builder

WORKDIR /app

COPY go.mod go.sum ./

RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux go build -o main .

# Use a minimal base image for the final stage
FROM scratch

#HTTPS Place Holder
#RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /app

# Copy the compiled binary from the builder stage
COPY --from=builder /app/main .
COPY --from=builder /app/views ./views
COPY --from=builder /app/.env .env

# Expose the port the app runs on
EXPOSE 4040

# Command to run the application
CMD ["./main"]