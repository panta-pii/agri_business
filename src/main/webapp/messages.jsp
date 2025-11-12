<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="javax.servlet.http.*, javax.servlet.*"%>
<%@page import="models.User"%>
<%
    HttpSession sessionObj = request.getSession(false);
    User user = (sessionObj != null) ? (User) sessionObj.getAttribute("user") : null;
    if (user == null) {
        response.sendRedirect("index.jsp?error=login_required");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Messages - AgriYouth Marketplace</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
        <style>
            :root {
                --primary-color: #28a745;
                --primary-dark: #218838;
                --sidebar-width: 250px;
            }

            .sidebar {
                width: var(--sidebar-width);
                height: 100vh;
                position: fixed;
                top: 0;
                left: 0;
                background: var(--primary-color);
                color: white;
                transition: all 0.3s;
                z-index: 1000;
            }

            .sidebar .nav-link {
                color: white;
                padding: 12px 20px;
                border-bottom: 1px solid rgba(255,255,255,0.1);
                transition: all 0.3s;
            }

            .sidebar .nav-link:hover {
                background: rgba(255,255,255,0.1);
                padding-left: 25px;
            }

            .sidebar .nav-link.active {
                background: rgba(255,255,255,0.2);
                border-left: 4px solid white;
            }

            .main-content {
                margin-left: var(--sidebar-width);
                padding: 20px;
                transition: all 0.3s;
            }

            @media (max-width: 768px) {
                .sidebar {
                    width: 0;
                    transform: translateX(-100%);
                }

                .sidebar.show {
                    width: var(--sidebar-width);
                    transform: translateX(0);
                }

                .main-content {
                    margin-left: 0;
                }
            }

            .messages-container {
                height: calc(100vh - 200px);
                background: white;
                border-radius: 10px;
                box-shadow: 0 2px 10px rgba(0,0,0,0.1);
                overflow: hidden;
            }

            .conversations-sidebar {
                border-right: 1px solid #dee2e6;
                height: 100%;
                overflow-y: auto;
            }

            .chat-area {
                height: 100%;
                display: flex;
                flex-direction: column;
            }

            .messages-list {
                flex: 1;
                overflow-y: auto;
                padding: 20px;
                background: #f8f9fa;
            }

            .message-input-area {
                border-top: 1px solid #dee2e6;
                padding: 15px;
                background: white;
            }

            .conversation-item {
                padding: 15px;
                border-bottom: 1px solid #f1f1f1;
                cursor: pointer;
                transition: background 0.2s;
            }

            .conversation-item:hover {
                background: #f8f9fa;
            }

            .conversation-item.active {
                background: #e9f7ef;
                border-left: 4px solid var(--primary-color);
            }

            .message {
                max-width: 70%;
                margin-bottom: 15px;
                padding: 10px 15px;
                border-radius: 15px;
                position: relative;
            }

            .message.sent {
                background: var(--primary-color);
                color: white;
                margin-left: auto;
                border-bottom-right-radius: 5px;
            }

            .message.received {
                background: white;
                border: 1px solid #dee2e6;
                margin-right: auto;
                border-bottom-left-radius: 5px;
            }

            .message-time {
                font-size: 0.75rem;
                opacity: 0.7;
                margin-top: 5px;
            }

            .unread-badge {
                background: #dc3545;
                color: white;
                border-radius: 50%;
                width: 20px;
                height: 20px;
                font-size: 0.75rem;
                display: flex;
                align-items: center;
                justify-content: center;
            }

            .chat-header {
                background: white;
                border-bottom: 1px solid #dee2e6;
                padding: 15px 20px;
            }

            .empty-state {
                text-align: center;
                padding: 40px;
                color: #6c757d;
            }

            .file-message {
                background: #e9ecef;
                border-radius: 8px;
                padding: 10px;
                margin: 5px 0;
            }

            .community-badge {
                background: #ffc107;
                color: #000;
                font-size: 0.7rem;
                padding: 2px 6px;
                border-radius: 10px;
                margin-left: 5px;
            }

            .conversation-category {
                background: #f8f9fa;
                padding: 8px 15px;
                font-weight: bold;
                color: #495057;
                border-bottom: 1px solid #dee2e6;
            }
        </style>
    </head>
    <body>
        <!-- Sidebar Navigation -->
        <div class="sidebar" id="sidebar">
            <div class="sidebar-header p-3 bg-success-dark">
                <h5 class="mb-0">
                    <i class="fas fa-tractor me-2"></i>
                    <%= user.getFirstName()%> <%= user.getLastName()%>
                </h5>
                <small class="text-white-50"><%= user.getRole().equals("FARMER") ? "Farmer Account" : "Buyer Account"%></small>
            </div>

            <nav class="nav flex-column mt-3">
                <a class="nav-link" href="index.jsp">
                    <i class="fas fa-home me-2"></i> Home
                </a>
                <a class="nav-link" href="profile.jsp">
                    <i class="fas fa-user me-2"></i> My Profile
                </a>
                <% if (user.getRole().equals("FARMER")) { %>
                <a class="nav-link" href="farmers_dashboard.jsp">
                    <i class="fas fa-shopping-bag me-2"></i> Orders Received
                </a>
                <a class="nav-link" href="product_management.jsp">
                    <i class="fas fa-plus-circle me-2"></i> Manage Products
                </a>
                <% } else { %>
                <a class="nav-link" href="buyer_dashboard.jsp">
                    <i class="fas fa-shopping-bag me-2"></i> My Orders
                </a>
                <% } %>
                <a class="nav-link active" href="messages.jsp">
                    <i class="fas fa-comments me-2"></i> Messages
                </a>
                <% if (user.getRole().equals("FARMER")) { %>
                <a class="nav-link" href="farmer_analytics.jsp">
                    <i class="fas fa-chart-bar me-2"></i> Analytics
                </a>
                <% }%>
                <div class="mt-4 p-3">
                    <a class="btn btn-outline-light btn-sm w-100" href="LogoutServlet">
                        <i class="fas fa-sign-out-alt me-2"></i> Logout
                    </a>
                </div>
            </nav>
        </div>

        <!-- Main Content -->
        <div class="main-content">
            <!-- Mobile Header -->
            <div class="d-md-none d-flex justify-content-between align-items-center mb-4 p-3 bg-white shadow-sm rounded">
                <button class="btn btn-success" id="sidebarToggle">
                    <i class="fas fa-bars"></i>
                </button>
                <h5 class="mb-0 text-success">Messages</h5>
                <div></div>
            </div>

            <!-- Page Header -->
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h2 class="text-success mb-1">
                        <i class="fas fa-comments me-2"></i>Messages
                    </h2>
                    <p class="text-muted mb-0">
                        <% if (user.getRole().equals("FARMER")) { %>
                        Connect with your buyers
                        <% } else { %>
                        Connect with farmers
                        <% }%>
                    </p>
                </div>
                <div class="btn-group">
                    <button class="btn btn-success" data-bs-toggle="modal" data-bs-target="#newMessageModal">
                        <i class="fas fa-plus me-2"></i>New Message
                    </button>
                    <button class="btn btn-outline-warning" onclick="joinCommunityChat()">
                        <i class="fas fa-users me-2"></i>Community Chat
                    </button>
                </div>
            </div>

            <!-- Messages Container -->
            <div class="messages-container">
                <div class="row h-100">
                    <!-- Conversations Sidebar -->
                    <div class="col-md-4 conversations-sidebar">
                        <div class="p-3 border-bottom">
                            <div class="input-group">
                                <input type="text" class="form-control" placeholder="Search conversations..." id="searchConversations">
                                <button class="btn btn-outline-secondary" type="button">
                                    <i class="fas fa-search"></i>
                                </button>
                            </div>
                        </div>
                        <div id="conversationsList">
                            <!-- Conversations will be loaded here -->
                        </div>
                    </div>

                    <!-- Chat Area -->
                    <div class="col-md-8 chat-area">
                        <div class="chat-header d-flex justify-content-between align-items-center">
                            <div id="currentChatInfo">
                                <h5 class="mb-0 text-muted">Select a conversation</h5>
                            </div>
                            <div id="chatActions" style="display: none;">
                                <button class="btn btn-sm btn-outline-secondary" id="viewParticipants">
                                    <i class="fas fa-users"></i>
                                </button>
                            </div>
                        </div>

                        <div class="messages-list" id="messagesList">
                            <div class="empty-state">
                                <i class="fas fa-comments fa-3x mb-3"></i>
                                <h5>No conversation selected</h5>
                                <p>Choose a conversation from the list or start a new one</p>
                            </div>
                        </div>

                        <div class="message-input-area" id="messageInputArea" style="display: none;">
                            <form id="messageForm" enctype="multipart/form-data">
                                <input type="hidden" id="currentConversationId">
                                <div class="row g-2 align-items-center">
                                    <div class="col-auto">
                                        <button type="button" class="btn btn-outline-secondary" id="attachFileBtn">
                                            <i class="fas fa-paperclip"></i>
                                        </button>
                                        <input type="file" id="fileInput" name="file" style="display: none;" accept="image/*,.pdf,.doc,.docx">
                                    </div>
                                    <div class="col">
                                        <input type="text" class="form-control" id="messageInput" 
                                               placeholder="Type your message..." name="content" required>
                                    </div>
                                    <div class="col-auto">
                                        <button type="submit" class="btn btn-success">
                                            <i class="fas fa-paper-plane"></i>
                                        </button>
                                    </div>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- New Message Modal -->
        <div class="modal fade" id="newMessageModal" tabindex="-1">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header bg-success text-white">
                        <h5 class="modal-title">New Message</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <div class="mb-3">
                            <label class="form-label">Search Users</label>
                            <input type="text" class="form-control" id="userSearch" placeholder="Search by name or email...">
                        </div>
                        <div id="searchResults" style="max-height: 300px; overflow-y: auto;">
                            <!-- Search results will appear here -->
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Participants Modal -->
        <div class="modal fade" id="participantsModal" tabindex="-1">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header bg-success text-white">
                        <h5 class="modal-title">Conversation Participants</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body" id="participantsList">
                        <!-- Participants will be loaded here -->
                    </div>
                </div>
            </div>
        </div>

        <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

        <script>
                           let currentConversationId = null;
                           let refreshInterval = null;
                           const COMMUNITY_CHAT_ID = 1; // Assuming community chat has ID 1
                           let selectedParticipants = [];

                           // Initialize
                           $(document).ready(function () {
                               loadConversations();
                               setupEventListeners();

                               // Refresh conversations every 10 seconds
                               refreshInterval = setInterval(loadConversations, 10000);
                           });

                           function setupEventListeners() {
                               // Sidebar toggle
                               $('#sidebarToggle').click(function () {
                                   $('#sidebar').toggleClass('show');
                               });

                               // User search
                               $('#userSearch').on('input', function () {
                                   const query = $(this).val();
                                   if (query.length >= 2) {
                                       searchUsers(query);
                                   } else {
                                       $('#searchResults').empty();
                                   }
                               });

                               // Group user search
                               $('#groupUserSearch').on('input', function () {
                                   const query = $(this).val();
                                   if (query.length >= 2) {
                                       searchUsersForGroup(query);
                                   } else {
                                       $('#groupSearchResults').empty();
                                   }
                               });

                               // Message form submission
                               $('#messageForm').on('submit', function (e) {
                                   e.preventDefault();
                                   sendMessage();
                               });

                               // File attachment
                               $('#attachFileBtn').click(function () {
                                   $('#fileInput').click();
                               });

                               $('#fileInput').change(function () {
                                   if (this.files.length > 0) {
                                       sendFileMessage();
                                   }
                               });

                               // Create group
                               $('#createGroupBtn').click(createGroup);

                               // Close modals on hide
                               $('#newMessageModal').on('hidden.bs.modal', function () {
                                   $('#userSearch').val('');
                                   $('#searchResults').empty();
                               });

                               $('#newGroupModal').on('hidden.bs.modal', function () {
                                   $('#groupName').val('');
                                   $('#groupUserSearch').val('');
                                   $('#groupSearchResults').empty();
                                   selectedParticipants = [];
                                   updateSelectedParticipants();
                               });
                           }

                           function loadConversations() {
                               $.get('MessageServlet', {action: 'getConversations'})
                                       .done(function (data) {
                                           try {
                                               // Check if it's already an object (error case)
                                               if (typeof data === 'object') {
                                                   if (data.success === false) {
                                                       showError('Failed to load conversations: ' + data.message);
                                                       return;
                                                   }
                                               } else {
                                                   // Parse JSON string
                                                   data = JSON.parse(data);
                                               }

                                               const conversations = data;
                                               const container = $('#conversationsList');
                                               container.empty();

                                               if (!conversations || conversations.length === 0) {
                                                   container.html('<div class="empty-state p-4"><i class="fas fa-comments fa-2x mb-3"></i><p class="text-muted">No conversations yet</p></div>');
                                                   return;
                                               }

                                               // Separate community chat from regular conversations
                                               const communityChats = conversations.filter(conv => conv.type === 'COMMUNITY');
                                               const regularChats = conversations.filter(conv => conv.type !== 'COMMUNITY');

                                               // Add community chat first
                                               if (communityChats.length > 0) {
                                                   container.append('<div class="conversation-category">Community</div>');
                                                   communityChats.forEach(conv => {
                                                       renderConversationItem(conv, container);
                                                   });
                                               }

                                               // Add regular conversations with appropriate category
                                               if (regularChats.length > 0) {
                                                   const categoryLabel = <%= user.getRole().equals("FARMER") ? "'Your Buyers'" : "'Farmers'"%>;
                                                   container.append('<div class="conversation-category">' + categoryLabel + '</div>');
                                                   regularChats.forEach(conv => {
                                                       renderConversationItem(conv, container);
                                                   });
                                               }

                                           } catch (e) {
                                               console.error('Error parsing conversations:', e, 'Data:', data);
                                               showError('Failed to load conversations. Please try again.');
                                           }
                                       })
                                       .fail(function (xhr, status, error) {
                                           console.error('Failed to load conversations:', error);
                                           showError('Failed to load conversations. Please try again.');
                                       });
                           }

                           function renderConversationItem(conv, container) {
                               const lastMessage = conv.lastMessage ?
                                       (conv.lastMessage.content.length > 50 ?
                                               conv.lastMessage.content.substring(0, 50) + '...' :
                                               conv.lastMessage.content) : 'No messages yet';

                               const time = conv.lastMessage ?
                                       formatTime(conv.lastMessage.createdAt) : '';

                               const unreadBadge = conv.unreadCount > 0 ?
                                       '<span class="unread-badge">' + conv.unreadCount + '</span>' : '';

                               const isActive = currentConversationId == conv.id ? 'active' : '';

                               const communityBadge = conv.type === 'COMMUNITY' ?
                                       '<span class="community-badge">Community</span>' : '';

                               container.append(
                                       '<div class="conversation-item ' + isActive + '" ' +
                                       'onclick="selectConversation(' + conv.id + ', \'' + escapeHtml(conv.name) + '\', \'' + conv.type + '\')">' +
                                       '<div class="d-flex justify-content-between align-items-start">' +
                                       '<div class="flex-grow-1">' +
                                       '<h6 class="mb-1">' + conv.name + communityBadge + '</h6>' +
                                       '<p class="mb-1 text-muted small">' + lastMessage + '</p>' +
                                       '<small class="text-muted">' + time + '</small>' +
                                       '</div>' +
                                       unreadBadge +
                                       '</div>' +
                                       '</div>'
                                       );
                           }

                           function selectConversation(conversationId, conversationName, conversationType) {
                               currentConversationId = conversationId;

                               // Update UI
                               $('.conversation-item').removeClass('active');
                               $(`.conversation-item[onclick*="${conversationId}"]`).addClass('active');

                               const conversationTypeText = conversationType === 'COMMUNITY' ?
                                       'Community Chat' :
                                       conversationType === 'GROUP' ? 'Group' : 'Direct message';

                               $('#currentChatInfo').html(
                                       '<h5 class="mb-0">' + conversationName + '</h5>' +
                                       '<small class="text-muted">' + conversationTypeText + '</small>'
                                       );

                               $('#chatActions').show();
                               $('#messageInputArea').show();
                               $('#messagesList').empty().removeClass('empty-state');

                               loadMessages(conversationId);
                               markAsRead(conversationId);
                           }

                           function loadMessages(conversationId) {
                               $.get('MessageServlet', {action: 'getMessages', conversationId: conversationId})
                                       .done(function (data) {
                                           try {
                                               // Check if it's already an object (error case)
                                               if (typeof data === 'object') {
                                                   if (data.success === false) {
                                                       showError('Failed to load messages: ' + data.message);
                                                       return;
                                                   }
                                               } else {
                                                   // Parse JSON string
                                                   data = JSON.parse(data);
                                               }

                                               const messages = data;
                                               const container = $('#messagesList');
                                               container.empty();

                                               if (!messages || messages.length === 0) {
                                                   container.html(
                                                           '<div class="empty-state">' +
                                                           '<i class="fas fa-comments fa-2x mb-3"></i>' +
                                                           '<p class="text-muted">No messages yet</p>' +
                                                           '<small>Start the conversation!</small>' +
                                                           '</div>'
                                                           );
                                                   return;
                                               }

                                               messages.forEach(msg => {
                                                   const isSent = msg.senderId === <%= user.getId()%>;
                                                   const messageClass = isSent ? 'sent' : 'received';
                                                   const time = formatTime(msg.createdAt);

                                                   let messageContent = escapeHtml(msg.content);
                                                   if (msg.messageType === 'FILE') {
                                                       let fileSizeHtml = '';
                                                       if (msg.fileSize) {
                                                           fileSizeHtml = '<small class="d-block text-muted">' + formatFileSize(msg.fileSize) + '</small>';
                                                       }
                                                       messageContent =
                                                               '<div class="file-message">' +
                                                               '<i class="fas fa-file me-2"></i>' +
                                                               '<a href="' + msg.fileUrl + '" target="_blank">' + (msg.fileName || 'Download') + '</a>' +
                                                               fileSizeHtml +
                                                               '</div>';
                                                   }

                                                   const senderNameHtml = !isSent && currentConversationId === COMMUNITY_CHAT_ID ?
                                                           '<small class="d-block fw-bold">' + (msg.senderName || 'Unknown') + '</small>' : '';

                                                   container.append(
                                                           '<div class="message ' + messageClass + '">' +
                                                           senderNameHtml +
                                                           '<div class="message-content">' + messageContent + '</div>' +
                                                           '<div class="message-time">' + time + '</div>' +
                                                           '</div>'
                                                           );
                                               });

                                               // Scroll to bottom
                                               container.scrollTop(container[0].scrollHeight);
                                           } catch (e) {
                                               console.error('Error parsing messages:', e, 'Data:', data);
                                               showError('Failed to load messages. Please try again.');
                                           }
                                       })
                                       .fail(function (xhr, status, error) {
                                           console.error('Failed to load messages:', error);
                                           showError('Failed to load messages. Please try again.');
                                       });
                           }

                           function sendMessage() {
                               const content = $('#messageInput').val().trim();
                               if (!content || !currentConversationId) {
                                   showError('Please enter a message and select a conversation');
                                   return;
                               }

                               const formData = new FormData();
                               formData.append('action', 'sendMessage');
                               formData.append('conversationId', currentConversationId);
                               formData.append('content', content);
                               formData.append('messageType', 'TEXT');

                               $.ajax({
                                   url: 'MessageServlet',
                                   type: 'POST',
                                   data: formData,
                                   processData: false,
                                   contentType: false,
                                   success: function (response) {
                                       try {
                                           const result = typeof response === 'object' ? response : JSON.parse(response);
                                           if (result.success) {
                                               $('#messageInput').val('');
                                               loadMessages(currentConversationId);
                                               loadConversations(); // Refresh conversation list
                                           } else {
                                               showError('Failed to send message: ' + result.message);
                                           }
                                       } catch (e) {
                                           console.error('Error parsing response:', e);
                                           showError('Error sending message');
                                       }
                                   },
                                   error: function (xhr, status, error) {
                                       console.error('Error sending message:', error);
                                       showError('Error sending message');
                                   }
                               });
                           }

                           function sendFileMessage() {
                               const fileInput = $('#fileInput')[0];
                               if (!fileInput.files.length || !currentConversationId) {
                                   showError('Please select a file and a conversation');
                                   return;
                               }

                               const formData = new FormData();
                               formData.append('action', 'sendMessage');
                               formData.append('conversationId', currentConversationId);
                               formData.append('file', fileInput.files[0]);
                               formData.append('messageType', 'FILE');
                               formData.append('content', 'Shared a file');

                               $.ajax({
                                   url: 'MessageServlet',
                                   type: 'POST',
                                   data: formData,
                                   processData: false,
                                   contentType: false,
                                   success: function (response) {
                                       try {
                                           const result = typeof response === 'object' ? response : JSON.parse(response);
                                           if (result.success) {
                                               $('#fileInput').val('');
                                               loadMessages(currentConversationId);
                                               loadConversations();
                                           } else {
                                               showError('Failed to send file: ' + result.message);
                                           }
                                       } catch (e) {
                                           console.error('Error parsing response:', e);
                                           showError('Error sending file');
                                       }
                                   },
                                   error: function (xhr, status, error) {
                                       console.error('Error sending file:', error);
                                       showError('Error sending file');
                                   }
                               });
                           }

                           function searchUsers(query) {
                               $.get('MessageServlet', {action: 'searchUsers', q: query})
                                       .done(function (data) {
                                           try {
                                               const users = typeof data === 'object' ? data : JSON.parse(data);
                                               const container = $('#searchResults');
                                               container.empty();

                                               if (!users || users.length === 0) {
                                                   container.html('<div class="p-2 text-muted">No users found</div>');
                                                   return;
                                               }

                                               users.forEach(user => {
                                                   container.append(
                                                           '<div class="user-result p-2 border-bottom" ' +
                                                           'onclick="startConversation(' + user.id + ', \'' + escapeHtml(user.name) + '\')" ' +
                                                           'style="cursor: pointer;">' +
                                                           '<div class="fw-bold">' + user.name + '</div>' +
                                                           '<small class="text-muted">' + user.email + ' • ' + user.role + '</small>' +
                                                           '</div>'
                                                           );
                                               });
                                           } catch (e) {
                                               console.error('Error parsing users:', e);
                                               $('#searchResults').html('<div class="p-2 text-danger">Error searching users</div>');
                                           }
                                       })
                                       .fail(function (xhr, status, error) {
                                           console.error('Search users failed:', error);
                                           $('#searchResults').html('<div class="p-2 text-danger">Search failed</div>');
                                       });
                           }

                           function startConversation(userId, userName) {
                               $.post('MessageServlet', {action: 'startConversation', userId: userId})
                                       .done(function (response) {
                                           try {
                                               const result = typeof response === 'object' ? response : JSON.parse(response);
                                               if (result.success) {
                                                   $('#newMessageModal').modal('hide');
                                                   loadConversations();
                                                   // Select the new conversation
                                                   setTimeout(() => {
                                                       if (result.conversationId) {
                                                           selectConversation(result.conversationId, userName, 'DIRECT');
                                                       }
                                                   }, 500);
                                               } else {
                                                   showError('Failed to start conversation: ' + result.message);
                                               }
                                           } catch (e) {
                                               console.error('Error parsing response:', e);
                                               showError('Error starting conversation');
                                           }
                                       })
                                       .fail(function (xhr, status, error) {
                                           console.error('Start conversation failed:', error);
                                           showError('Error starting conversation');
                                       });
                           }

                           function markAsRead(conversationId) {
                               $.post('MessageServlet', {action: 'markAsRead', conversationId: conversationId})
                                       .fail(function (xhr, status, error) {
                                           console.error('Mark as read failed:', error);
                                       });
                           }

                           function joinCommunityChat() {
                               // Assuming community chat has a fixed ID of 1
                               // You might want to create a servlet endpoint to get or create community chat
                               selectConversation(COMMUNITY_CHAT_ID, 'AgriYouth Community', 'COMMUNITY');
                           }

                           function formatTime(timestamp) {
                               const date = new Date(timestamp);
                               return date.toLocaleTimeString([], {hour: '2-digit', minute: '2-digit'});
                           }

                           function formatFileSize(bytes) {
                               if (!bytes)
                                   return '';
                               if (bytes === 0)
                                   return '0 Bytes';
                               const k = 1024;
                               const sizes = ['Bytes', 'KB', 'MB', 'GB'];
                               const i = Math.floor(Math.log(bytes) / Math.log(k));
                               return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
                           }

                           function escapeHtml(text) {
                               const div = document.createElement('div');
                               div.textContent = text;
                               return div.innerHTML;
                           }

                           function showError(message) {
                               alert('Error: ' + message);
                           }

                           // Group chat functionality
                           function searchUsersForGroup(query) {
                               $.get('MessageServlet', {action: 'searchUsers', q: query})
                                       .done(function (data) {
                                           try {
                                               const users = typeof data === 'object' ? data : JSON.parse(data);
                                               const container = $('#groupSearchResults');
                                               container.empty();

                                               if (!users || users.length === 0) {
                                                   container.html('<div class="p-2 text-muted">No users found</div>');
                                                   return;
                                               }

                                               users.forEach(user => {
                                                   if (!selectedParticipants.find(p => p.id === user.id)) {
                                                       container.append(
                                                               '<div class="user-result p-2 border-bottom" ' +
                                                               'onclick="addParticipant(' + user.id + ', \'' + escapeHtml(user.name) + '\', \'' + user.email + '\')" ' +
                                                               'style="cursor: pointer;">' +
                                                               '<div class="fw-bold">' + user.name + '</div>' +
                                                               '<small class="text-muted">' + user.email + '</small>' +
                                                               '</div>'
                                                               );
                                                   }
                                               });
                                           } catch (e) {
                                               console.error('Error parsing users:', e);
                                               $('#groupSearchResults').html('<div class="p-2 text-danger">Search failed</div>');
                                           }
                                       })
                                       .fail(function (xhr, status, error) {
                                           console.error('Search users failed:', error);
                                           $('#groupSearchResults').html('<div class="p-2 text-danger">Search failed</div>');
                                       });
                           }

                           function addParticipant(userId, userName, userEmail) {
                               if (!selectedParticipants.find(p => p.id === userId)) {
                                   selectedParticipants.push({id: userId, name: userName, email: userEmail});
                                   updateSelectedParticipants();
                               }
                               $('#groupUserSearch').val('');
                               $('#groupSearchResults').empty();
                           }

                           function updateSelectedParticipants() {
                               const container = $('#selectedParticipants');
                               container.empty();

                               if (selectedParticipants.length === 0) {
                                   container.html('<small class="text-muted">Selected participants will appear here</small>');
                                   return;
                               }

                               selectedParticipants.forEach((participant, index) => {
                                   container.append(
                                           '<span class="badge bg-success me-2 mb-2">' +
                                           participant.name +
                                           '<button type="button" class="btn-close btn-close-white ms-1" ' +
                                           'onclick="removeParticipant(' + index + ')" style="font-size: 0.7rem;"></button>' +
                                           '</span>'
                                           );
                               });
                           }

                           function removeParticipant(index) {
                               selectedParticipants.splice(index, 1);
                               updateSelectedParticipants();
                           }

                           function createGroup() {
                               const groupName = $('#groupName').val().trim();
                               if (!groupName) {
                                   showError('Please enter a group name');
                                   return;
                               }

                               if (selectedParticipants.length === 0) {
                                   showError('Please add at least one participant');
                                   return;
                               }

                               const participantIds = selectedParticipants.map(p => p.id);

                               $.post('MessageServlet', {
                                   action: 'createGroup',
                                   groupName: groupName,
                                   participants: participantIds
                               })
                                       .done(function (response) {
                                           try {
                                               const result = typeof response === 'object' ? response : JSON.parse(response);
                                               if (result.success) {
                                                   $('#newGroupModal').modal('hide');
                                                   $('#groupName').val('');
                                                   selectedParticipants = [];
                                                   updateSelectedParticipants();
                                                   loadConversations();
                                                   // Select the new group
                                                   setTimeout(() => {
                                                       if (result.conversationId) {
                                                           selectConversation(result.conversationId, groupName, 'GROUP');
                                                       }
                                                   }, 500);
                                               } else {
                                                   showError('Failed to create group: ' + result.message);
                                               }
                                           } catch (e) {
                                               console.error('Error parsing response:', e);
                                               showError('Error creating group');
                                           }
                                       })
                                       .fail(function (xhr, status, error) {
                                           console.error('Create group failed:', error);
                                           showError('Error creating group');
                                       });
                           }

                           // View participants
                           $('#viewParticipants').click(function () {
                               if (!currentConversationId)
                                   return;

                               $.get('MessageServlet', {action: 'getConversationDetails', conversationId: currentConversationId})
                                       .done(function (data) {
                                           try {
                                               const participants = typeof data === 'object' ? data : JSON.parse(data);
                                               const container = $('#participantsList');
                                               container.empty();

                                               participants.forEach(user => {
                                                   container.append(
                                                           '<div class="d-flex justify-content-between align-items-center p-2 border-bottom">' +
                                                           '<div>' +
                                                           '<div class="fw-bold">' + user.name + '</div>' +
                                                           '<small class="text-muted">' + user.email + ' • ' + user.role + '</small>' +
                                                           '</div>' +
                                                           '</div>'
                                                           );
                                               });

                                               $('#participantsModal').modal('show');
                                           } catch (e) {
                                               console.error('Error parsing participants:', e, 'Data:', data);
                                               showError('Failed to load participants');
                                           }
                                       })
                                       .fail(function (xhr, status, error) {
                                           console.error('Get participants failed:', error);
                                           showError('Failed to load participants');
                                       });
                           });
        </script>
    </body>
</html>