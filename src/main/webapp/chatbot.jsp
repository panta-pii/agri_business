<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // Check if user is logged in (copied from index.jsp for consistency)
    String userEmail = (String) session.getAttribute("userEmail");
    String userName = (String) session.getAttribute("userName");
    boolean isLoggedIn = userEmail != null;
    String userRole = null;

    if (session != null && session.getAttribute("userEmail") != null) {
        isLoggedIn = true;
        userName = (String) session.getAttribute("userName");
        userEmail = (String) session.getAttribute("userEmail");
        userRole = (String) session.getAttribute("userRole");
    }
%>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>AgriBot Chat - AgriYouth Marketplace</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
        <style>
            :root {
                --primary-color: #28a745;
                --primary-dark: #218838;
                --light-bg: #f8f9fa;
                --card-shadow: 0 5px 15px rgba(0,0,0,0.08);
                --hover-shadow: 0 10px 25px rgba(0,0,0,0.15);
            }

            body {
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                background-color: var(--light-bg);
                min-height: 100vh;
                display: flex;
                flex-direction: column;
            }

            .navbar-brand {
                font-weight: 700;
                font-size: 1.4rem;
            }

            .nav-button {
                margin: 0 5px;
                border-radius: 6px;
                transition: all 0.3s ease;
            }

            .nav-button:hover {
                transform: translateY(-2px);
                box-shadow: 0 4px 8px rgba(0,0,0,0.1);
            }

            .chat-container {
                max-width: 800px;
                margin: 20px auto;
                background: white;
                border-radius: 12px;
                box-shadow: var(--card-shadow);
                overflow: hidden;
                flex-grow: 1;
                display: flex;
                flex-direction: column;
            }

            .chat-header {
                background: var(--primary-color);
                color: white;
                padding: 15px;
                font-weight: 600;
                display: flex;
                justify-content: space-between;
                align-items: center;
            }

            .chat-window {
                flex-grow: 1;
                max-height: calc(100vh - 250px);
                overflow-y: auto;
                padding: 15px;
                display: flex;
                flex-direction: column;
                gap: 12px;
            }

            .chat-message {
                padding: 12px 15px;
                border-radius: 8px;
                max-width: 80%;
                word-wrap: break-word;
            }

            .chat-bot {
                background: #e9f7ef;
                align-self: flex-start;
            }

            .chat-user {
                background: #d1e7dd;
                align-self: flex-end;
            }

            .chat-typing {
                background: #e9f7ef;
                align-self: flex-start;
                font-style: italic;
                color: gray;
            }

            .chat-input {
                display: flex;
                padding: 10px;
                border-top: 1px solid #eee;
                background: #fafafa;
            }

            .chat-input input {
                flex: 1;
                margin-right: 8px;
            }

            .chat-input button {
                background: var(--primary-color);
                border: none;
                color: white;
            }

            .chat-input button:hover {
                background: var(--primary-dark);
            }

            footer {
                margin-top: auto;
            }

            @media (max-width: 768px) {
                .chat-container {
                    margin: 10px;
                    border-radius: 0;
                }
            }
        </style>
    </head>
    <body>
        <!-- Navigation Bar (copied from index.jsp for consistency) -->
        <nav class="navbar navbar-expand-lg navbar-dark bg-success sticky-top shadow">
            <div class="container">
                <a class="navbar-brand" href="index.jsp">
                    <i class="fas fa-leaf"></i> AgriYouth Marketplace
                </a>
                <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                    <span class="navbar-toggler-icon"></span>
                </button>
                <div class="collapse navbar-collapse" id="navbarNav">
                    <div class="navbar-nav me-auto">
                        <a class="btn btn-outline-light nav-button" href="opportunities.jsp">
                            <i class="fas fa-briefcase"></i> Opportunities  
                        </a>
                        <a class="btn btn-outline-light nav-button" href="learning-materials">
                            <i class="fas fa-graduation-cap"></i> Learning Hub
                        </a>
                        <a class="btn btn-outline-light nav-button" href="Product_lising.jsp">
                            <i class="fas fa-store"></i> All Products
                        </a>

                        <% if (isLoggedIn) { %>
                        <!-- Logged-in users see their correct dashboard -->
                        <% if ("FARMER".equalsIgnoreCase(userRole)) { %>
                        <a class="btn btn-outline-light nav-button" href="farmers_dashboard.jsp">
                            <i class="fas fa-tachometer-alt"></i> My Dashboard
                        </a>
                        <% } else if ("BUYER".equalsIgnoreCase(userRole)) { %>
                        <a class="btn btn-outline-light nav-button" href="buyer_dashboard.jsp">
                            <i class="fas fa-tachometer-alt"></i> My Dashboard
                        </a>
                        <% } else if ("ADMIN".equalsIgnoreCase(userRole)) { %>
                        <a class="btn btn-outline-light nav-button" href="admin_dashboard.jsp">
                            <i class="fas fa-tachometer-alt"></i> My Dashboard
                        </a>
                        <% } else { %>
                        <a class="btn btn-outline-light nav-button" href="dashboard.jsp">
                            <i class="fas fa-tachometer-alt"></i> My Dashboard
                        </a>
                        <% } %>
                        <% } else { %>
                        <!-- Not logged in: show login modal -->
                        <button class="btn btn-outline-light nav-button" data-bs-toggle="modal" data-bs-target="#loginModal">
                            <i class="fas fa-tachometer-alt"></i> My Dashboard
                        </button>
                        <% } %>
                    </div>

                    <div class="navbar-nav ms-auto">
                        <% if (isLoggedIn) {%>
                        <span class="user-welcome text-white me-3">
                            <i class="fas fa-user me-1"></i> Welcome, <%= userName != null ? userName : userEmail%>
                        </span>
                        <a class="btn btn-outline-light nav-button" href="LogoutServlet">
                            <i class="fas fa-sign-out-alt"></i> Logout
                        </a>
                        <% } else { %>
                        <button class="btn btn-outline-light nav-button" data-bs-toggle="modal" data-bs-target="#loginModal">
                            <i class="fas fa-sign-in-alt"></i> Sign In
                        </button>
                        <button class="btn btn-light nav-button" data-bs-toggle="modal" data-bs-target="#registerModal">
                            <i class="fas fa-user-plus"></i> Register
                        </button>
                        <% }%>
                        <button class="btn btn-warning nav-button position-relative" id="cartButton">
                            <i class="fas fa-shopping-cart"></i> Cart 
                            <span class="badge bg-danger position-absolute top-0 start-100 translate-middle rounded-pill" id="cartCount">0</span>
                        </button>
                    </div>
                </div>
            </div>
        </nav>

        <!-- Main Chat Container -->
        <div class="chat-container">
            <div class="chat-header">
                <span><i class="fas fa-seedling me-2"></i> AgriBot - Powered by Google Gemini</span>
                <a href="index.jsp" class="btn-close btn-close-white" aria-label="Close"></a>
            </div>

            <div class="chat-window" id="chat-window">
                <div class="chat-message chat-bot">
                    Welcome! I'm AgriBot, powered by Google Gemini. Ask me about crops, livestock, agri-market trends, or anything related to agriculture!
                </div>
            </div>

            <div class="chat-input">
                <input type="text" id="chat-input-text" class="form-control" placeholder="Ask me anything..." onkeypress="if (event.key === 'Enter')
                            sendMessage()">
                <button class="btn" onclick="sendMessage()">
                    <i class="fas fa-paper-plane"></i>
                </button>
            </div>
        </div>

        <!-- Footer (copied from index.jsp) -->
        <footer class="bg-dark text-white py-4 text-center">
            <p class="mb-0">© 2025 AgriYouth Marketplace. All rights reserved.</p>
        </footer>

        <!-- Scripts -->
        <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
        <script>
                    const GEMINI_API_KEY = "AIzaSyASe6B-IW9Vf1AKTID9yYVLwpGdQzxIG2s";
                    // New, corrected URL with the standard model name
                    const GEMINI_API_URL = "https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash:generateContent?key=" + GEMINI_API_KEY;

                    let chatHistory = [
                        {role: "user", parts: [{text: "You are AgriBot, a friendly AI assistant for farmers in Lesotho. Focus on agriculture, crops, markets, and youth in farming. Keep answers short and helpful."}]},
                        {role: "model", parts: [{text: "Hello! I'm AgriBot. Ask me anything about farming in Lesotho!"}]}
                    ];

                    async function sendMessage() {
                        const input = document.getElementById('chat-input-text');
                        const message = input.value.trim();
                        if (!message)
                            return;

                        addMessage(message, 'user');
                        input.value = '';

                        const typingId = 'typing-' + Date.now();
                        addMessage('<i class="fas fa-circle-notch fa-spin"></i> AgriBot is thinking...', 'typing', typingId);

                        chatHistory.push({role: "user", parts: [{text: message}]});

                        try {
                            console.log("Sending to:", GEMINI_API_URL);

                            const response = await fetch(GEMINI_API_URL, {
                                method: 'POST',
                                headers: {
                                    'Content-Type': 'application/json',
                                    'Referer': window.location.href
                                },
                                body: JSON.stringify({
                                    contents: chatHistory,
                                    generationConfig: {
                                        temperature: 0.7,
                                        maxOutputTokens: 256
                                    }
                                })
                            });

                            if (!response.ok) {
                                const errText = await response.text();
                                throw new Error(`HTTP ${response.status}: ${errText}`);
                            }

                            const data = await response.json();
                            const reply = data.candidates[0].content.parts[0].text;

                            document.getElementById(typingId)?.remove();
                            addMessage(reply, 'bot');
                            chatHistory.push({role: "model", parts: [{text: reply}]});

                        } catch (err) {
                            console.error('Full Gemini Error:', err);
                            document.getElementById(typingId)?.remove();
                            addMessage(`Error: ${err.message}`, 'bot');
                        }
                    }

                    function addMessage(text, type, id = null) {
                        const chatWindow = document.getElementById('chat-window');
                        const div = document.createElement('div');
                        div.className = `chat-message chat-${type}`;
                        if (id)
                            div.id = id;

                        if (type === 'bot' || type === 'typing') {
                            div.innerHTML = text;
                        } else {
                            div.innerHTML = `<strong>You:</strong> ${text}`;
                        }
                        chatWindow.appendChild(div);
                        chatWindow.scrollTop = chatWindow.scrollHeight;
                    }

                    document.getElementById('chat-input-text').addEventListener('keypress', function (e) {
                        if (e.key === 'Enter') {
                            sendMessage();
                        }
                    });
        </script>
    </body>
</html>