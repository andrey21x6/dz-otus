FROM alpine:3.16.2

RUN apk --no-cache \
    add --update nginx && \
    rm -rf /var/cache/apk/*
	
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/default.conf /etc/nginx/conf.d/default.conf
COPY website /usr/share/nginx/html

EXPOSE 80/tcp

ENTRYPOINT ["nginx", "-g", "daemon off;"]
