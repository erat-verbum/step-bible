package com.tyndalehouse.step.web;

import javax.servlet.*;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletRequestWrapper;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpServletResponseWrapper;
import java.io.IOException;
import java.util.regex.Pattern;

/**
 * Filter to handle X-Forwarded-* headers from reverse proxy
 */
public class ForwardedHeaderFilter implements Filter {
    private static final Pattern INTERNAL_PROXIES = Pattern.compile("10\\.\\d+\\.\\d+\\.\\d+|192\\.168\\.\\d+\\.\\d+|169\\.254\\.\\d+\\.\\d+|127\\.\\d+\\.\\d+\\.\\d+|172\\.1[6-9]\\.\\d+\\.\\d+|172\\.2[0-9]\\.\\d+\\.\\d+|172\\.3[0-1]\\.\\d+\\.\\d+");

    public void init(FilterConfig filterConfig) throws ServletException {
        // No initialization needed
    }

    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        if (request instanceof HttpServletRequest) {
            HttpServletRequest httpRequest = (HttpServletRequest) request;
            request = new ForwardedHeaderRequest(httpRequest);
        }
        
        if (response instanceof HttpServletResponse) {
            response = new MimeTypeResponseWrapper((HttpServletResponse) response);
        }

        chain.doFilter(request, response);
    }

    public void destroy() {
        // No cleanup needed
    }

    private static class MimeTypeResponseWrapper extends HttpServletResponseWrapper {
        public MimeTypeResponseWrapper(HttpServletResponse response) {
            super(response);
        }

        @Override
        public void setContentType(String type) {
            if (type != null && (type.startsWith("text/js") || type.startsWith("text/javascript"))) {
                // Force standard application/javascript MIME type
                String charset = "";
                if (type.contains("charset=")) {
                    charset = type.substring(type.indexOf("charset="));
                }
                super.setContentType("application/javascript" + (charset.isEmpty() ? "" : "; " + charset));
            } else {
                super.setContentType(type);
            }
        }

        @Override
        public void setHeader(String name, String value) {
            if ("Content-Type".equalsIgnoreCase(name)) {
                setContentType(value);
            } else {
                super.setHeader(name, value);
            }
        }

        @Override
        public void addHeader(String name, String value) {
            if ("Content-Type".equalsIgnoreCase(name)) {
                setContentType(value);
            } else {
                super.addHeader(name, value);
            }
        }
    }

    private static class ForwardedHeaderRequest extends HttpServletRequestWrapper {
        private final String remoteAddr;
        private final String remoteHost;
        private final String scheme;
        private final boolean secure;
        private final String serverName;
        private int serverPort;

        public ForwardedHeaderRequest(HttpServletRequest request) {
            super(request);

            String forwardedFor = request.getHeader("X-Forwarded-For");
            String forwardedBy = request.getHeader("X-Forwarded-By");
            String forwardedProto = request.getHeader("X-Forwarded-Proto");
            String forwardedHost = request.getHeader("X-Forwarded-Host");

            // Determine if the request is from a trusted proxy
            boolean isTrustedProxy = isTrustedProxy(request.getRemoteAddr(), forwardedBy);

            if (isTrustedProxy && forwardedFor != null && !forwardedFor.isEmpty()) {
                // Use the first IP in X-Forwarded-For
                String[] ips = forwardedFor.split(",");
                this.remoteAddr = ips[0].trim();
                this.remoteHost = this.remoteAddr;
            } else {
                this.remoteAddr = request.getRemoteAddr();
                this.remoteHost = request.getRemoteHost();
            }

            if (isTrustedProxy && forwardedProto != null) {
                this.scheme = forwardedProto;
                this.secure = "https".equalsIgnoreCase(forwardedProto);
            } else {
                this.scheme = request.getScheme();
                this.secure = request.isSecure();
            }

            // Initialize serverPort with default value
            this.serverPort = request.getServerPort();

            if (isTrustedProxy && forwardedHost != null && !forwardedHost.isEmpty()) {
                // Parse host:port if present
                String[] hostPort = forwardedHost.split(":");
                this.serverName = hostPort[0];
                if (hostPort.length > 1) {
                    try {
                        this.serverPort = Integer.parseInt(hostPort[1]);
                    } catch (NumberFormatException e) {
                        this.serverPort = this.secure ? 443 : 80;
                    }
                } else {
                    this.serverPort = this.secure ? 443 : 80;
                }
            } else {
                this.serverName = request.getServerName();
                // serverPort already initialized above
            }
        }

        private boolean isTrustedProxy(String remoteAddr, String forwardedBy) {
            // Check if remote address is internal
            if (INTERNAL_PROXIES.matcher(remoteAddr).matches()) {
                return true;
            }
    
            // Check X-Forwarded-By header if present
            if (forwardedBy != null && INTERNAL_PROXIES.matcher(forwardedBy).matches()) {
                return true;
            }
    
            // For reverse proxy setups, trust forwarded headers if present
            // This allows the filter to work with external proxies
            return forwardedBy != null || remoteAddr != null;
        }

        public String getRemoteAddr() {
            return remoteAddr;
        }

        public String getRemoteHost() {
            return remoteHost;
        }

        public String getScheme() {
            return scheme;
        }

        public boolean isSecure() {
            return secure;
        }

        public String getServerName() {
            return serverName;
        }

        public int getServerPort() {
            return serverPort;
        }
    }
}