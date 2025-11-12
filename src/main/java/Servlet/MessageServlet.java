package Servlet;

import daos.MessageDAO;
import models.Conversation;
import models.Message;
import models.User;

import javax.servlet.*;
import javax.servlet.annotation.*;
import javax.servlet.http.*;
import java.io.*;
import java.util.*;
import org.json.JSONObject;
import org.json.JSONArray;

@WebServlet("/MessageServlet")
@MultipartConfig(maxFileSize = 10 * 1024 * 1024) // 10MB max file size
public class MessageServlet extends HttpServlet {
    
    private MessageDAO messageDAO;
    
    @Override
    public void init() {
        messageDAO = new MessageDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            sendError(response, "Not authenticated");
            return;
        }
        
        User currentUser = (User) session.getAttribute("user");
        String action = request.getParameter("action");
        
        try {
            if (action == null) {
                sendError(response, "Action parameter is required");
                return;
            }
            
            switch (action) {
                case "getConversations":
                    getRoleBasedConversations(currentUser.getId(), currentUser.getRole(), response);
                    break;
                case "getMessages":
                    getMessages(request, currentUser.getId(), response);
                    break;
                case "searchUsers":
                    searchUsers(request, currentUser.getId(), response);
                    break;
                case "getConversationDetails":
                    getConversationDetails(request, currentUser.getId(), response);
                    break;
                case "joinCommunity":
                    joinCommunityChat(currentUser.getId(), response);
                    break;
                default:
                    sendError(response, "Invalid action: " + action);
            }
        } catch (Exception e) {
            e.printStackTrace();
            sendError(response, "Server error: " + e.getMessage());
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            sendError(response, "Not authenticated");
            return;
        }
        
        User currentUser = (User) session.getAttribute("user");
        String action = request.getParameter("action");
        
        try {
            if (action == null) {
                sendError(response, "Action parameter is required");
                return;
            }
            
            switch (action) {
                case "sendMessage":
                    sendMessage(request, currentUser.getId(), response);
                    break;
                case "createGroup":
                    createGroupConversation(request, currentUser.getId(), response);
                    break;
                case "startConversation":
                    startConversation(request, currentUser.getId(), response);
                    break;
                case "markAsRead":
                    markAsRead(request, currentUser.getId(), response);
                    break;
                default:
                    sendError(response, "Invalid action: " + action);
            }
        } catch (Exception e) {
            e.printStackTrace();
            sendError(response, "Server error: " + e.getMessage());
        }
    }
    
    private void getRoleBasedConversations(int userId, String userRole, HttpServletResponse response) throws Exception {
        try {
            List<Conversation> conversations = messageDAO.getRoleBasedConversations(userId, userRole);
            JSONArray jsonArray = new JSONArray();
            
            for (Conversation conv : conversations) {
                JSONObject json = new JSONObject();
                json.put("id", conv.getId());
                json.put("name", conv.getDisplayName(userId));
                json.put("type", conv.getType());
                json.put("unreadCount", conv.getUnreadCount());
                
                if (conv.getUpdatedAt() != null) {
                    json.put("updatedAt", conv.getUpdatedAt().getTime());
                } else if (conv.getCreatedAt() != null) {
                    json.put("updatedAt", conv.getCreatedAt().getTime());
                } else {
                    json.put("updatedAt", System.currentTimeMillis());
                }
                
                if (conv.getLastMessage() != null) {
                    JSONObject lastMessage = new JSONObject();
                    lastMessage.put("content", conv.getLastMessage().getContent() != null ? 
                        conv.getLastMessage().getContent() : "");
                    lastMessage.put("senderName", conv.getLastMessage().getSenderName() != null ? 
                        conv.getLastMessage().getSenderName() : "Unknown");
                    lastMessage.put("createdAt", conv.getLastMessage().getCreatedAt().getTime());
                    json.put("lastMessage", lastMessage);
                }
                
                // Add participant names for display
                if (conv.getParticipants() != null) {
                    JSONArray participants = new JSONArray();
                    for (User participant : conv.getParticipants()) {
                        if (participant.getId() != userId) {
                            participants.put(participant.getFirstName() + " " + participant.getLastName());
                        }
                    }
                    json.put("participantNames", participants);
                }
                
                jsonArray.put(json);
            }
            
            response.getWriter().print(jsonArray.toString());
            
        } catch (Exception e) {
            e.printStackTrace();
            sendError(response, "Error loading conversations: " + e.getMessage());
        }
    }
    
    private void getMessages(HttpServletRequest request, int userId, HttpServletResponse response) throws Exception {
        try {
            String conversationIdParam = request.getParameter("conversationId");
            if (conversationIdParam == null || conversationIdParam.trim().isEmpty()) {
                sendError(response, "Conversation ID is required");
                return;
            }
            
            int conversationId = Integer.parseInt(conversationIdParam);
            
            // Mark messages as read
            messageDAO.markMessagesAsRead(conversationId, userId);
            
            List<Message> messages = messageDAO.getMessagesForConversation(conversationId, userId);
            JSONArray jsonArray = new JSONArray();
            
            for (Message message : messages) {
                JSONObject json = new JSONObject();
                json.put("id", message.getId());
                json.put("senderId", message.getSenderId());
                json.put("senderName", message.getSenderName() != null ? message.getSenderName() : "Unknown");
                json.put("content", message.getContent() != null ? message.getContent() : "");
                json.put("messageType", message.getMessageType() != null ? message.getMessageType() : "TEXT");
                json.put("isRead", message.isRead());
                json.put("createdAt", message.getCreatedAt().getTime());
                
                if (message.getFileUrl() != null) {
                    json.put("fileUrl", message.getFileUrl());
                    json.put("fileName", message.getFileName());
                    json.put("fileSize", message.getFileSize());
                }
                
                jsonArray.put(json);
            }
            
            response.getWriter().print(jsonArray.toString());
            
        } catch (NumberFormatException e) {
            sendError(response, "Invalid conversation ID format");
        } catch (Exception e) {
            e.printStackTrace();
            sendError(response, "Error loading messages: " + e.getMessage());
        }
    }
    
    private void sendMessage(HttpServletRequest request, int userId, HttpServletResponse response) throws Exception {
        try {
            String conversationIdParam = request.getParameter("conversationId");
            String content = request.getParameter("content");
            String messageType = request.getParameter("messageType");
            
            if (conversationIdParam == null || conversationIdParam.trim().isEmpty()) {
                sendError(response, "Conversation ID is required");
                return;
            }
            
            int conversationId = Integer.parseInt(conversationIdParam);
            
            if (content == null || content.trim().isEmpty()) {
                sendError(response, "Message content cannot be empty");
                return;
            }
            
            Message message = new Message(conversationId, userId, messageType != null ? messageType : "TEXT", content.trim());
            
            // Handle file upload
            Part filePart = request.getPart("file");
            if (filePart != null && filePart.getSize() > 0) {
                String fileName = getFileName(filePart);
                String fileUrl = saveUploadedFile(filePart, fileName);
                message.setFileUrl(fileUrl);
                message.setFileName(fileName);
                message.setFileSize((int) filePart.getSize());
                message.setMessageType("FILE");
            }
            
            int messageId = messageDAO.sendMessage(message);
            
            JSONObject json = new JSONObject();
            if (messageId > 0) {
                json.put("success", true);
                json.put("messageId", messageId);
            } else {
                json.put("success", false);
                json.put("message", "Failed to send message");
            }
            
            response.getWriter().print(json.toString());
            
        } catch (NumberFormatException e) {
            sendError(response, "Invalid conversation ID format");
        } catch (Exception e) {
            e.printStackTrace();
            sendError(response, "Error sending message: " + e.getMessage());
        }
    }
    
    private void startConversation(HttpServletRequest request, int userId, HttpServletResponse response) throws Exception {
        try {
            String userIdParam = request.getParameter("userId");
            if (userIdParam == null || userIdParam.trim().isEmpty()) {
                sendError(response, "User ID is required");
                return;
            }
            
            int otherUserId = Integer.parseInt(userIdParam);
            
            int conversationId = messageDAO.getOrCreateDirectConversation(userId, otherUserId);
            
            JSONObject json = new JSONObject();
            json.put("success", true);
            json.put("conversationId", conversationId);
            
            response.getWriter().print(json.toString());
            
        } catch (NumberFormatException e) {
            sendError(response, "Invalid user ID format");
        } catch (Exception e) {
            e.printStackTrace();
            sendError(response, "Error starting conversation: " + e.getMessage());
        }
    }
    
    private void createGroupConversation(HttpServletRequest request, int userId, HttpServletResponse response) throws Exception {
        try {
            String groupName = request.getParameter("groupName");
            String[] participantIds = request.getParameterValues("participants[]");
            
            if (groupName == null || groupName.trim().isEmpty()) {
                sendError(response, "Group name is required");
                return;
            }
            
            if (participantIds == null || participantIds.length == 0) {
                sendError(response, "Select at least one participant");
                return;
            }
            
            List<Integer> participants = new ArrayList<>();
            for (String id : participantIds) {
                try {
                    participants.add(Integer.parseInt(id));
                } catch (NumberFormatException e) {
                    sendError(response, "Invalid participant ID: " + id);
                    return;
                }
            }
            
            int conversationId = messageDAO.createGroupConversation(groupName.trim(), userId, participants);
            
            JSONObject json = new JSONObject();
            json.put("success", true);
            json.put("conversationId", conversationId);
            
            response.getWriter().print(json.toString());
            
        } catch (Exception e) {
            e.printStackTrace();
            sendError(response, "Error creating group: " + e.getMessage());
        }
    }
    
    private void searchUsers(HttpServletRequest request, int userId, HttpServletResponse response) throws Exception {
        try {
            String query = request.getParameter("q");
            if (query == null || query.trim().isEmpty()) {
                sendError(response, "Search query is required");
                return;
            }
            
            List<User> users = messageDAO.searchUsers(query.trim(), userId);
            JSONArray jsonArray = new JSONArray();
            
            for (User user : users) {
                JSONObject json = new JSONObject();
                json.put("id", user.getId());
                json.put("name", user.getFirstName() + " " + user.getLastName());
                json.put("email", user.getEmail());
                json.put("role", user.getRole());
                jsonArray.put(json);
            }
            
            response.getWriter().print(jsonArray.toString());
            
        } catch (Exception e) {
            e.printStackTrace();
            sendError(response, "Error searching users: " + e.getMessage());
        }
    }
    
    private void getConversationDetails(HttpServletRequest request, int userId, HttpServletResponse response) throws Exception {
        try {
            String conversationIdParam = request.getParameter("conversationId");
            if (conversationIdParam == null || conversationIdParam.trim().isEmpty()) {
                sendError(response, "Conversation ID is required");
                return;
            }
            
            int conversationId = Integer.parseInt(conversationIdParam);
            List<User> participants = messageDAO.getConversationParticipants(conversationId);
            
            JSONArray jsonArray = new JSONArray();
            for (User user : participants) {
                JSONObject json = new JSONObject();
                json.put("id", user.getId());
                json.put("name", user.getFirstName() + " " + user.getLastName());
                json.put("email", user.getEmail());
                json.put("role", user.getRole());
                jsonArray.put(json);
            }
            
            response.getWriter().print(jsonArray.toString());
            
        } catch (NumberFormatException e) {
            sendError(response, "Invalid conversation ID format");
        } catch (Exception e) {
            e.printStackTrace();
            sendError(response, "Error loading conversation details: " + e.getMessage());
        }
    }
    
    private void joinCommunityChat(int userId, HttpServletResponse response) throws Exception {
        try {
            messageDAO.addUserToCommunityChat(userId);
            int communityId = messageDAO.getOrCreateCommunityChat();
            
            JSONObject json = new JSONObject();
            json.put("success", true);
            json.put("conversationId", communityId);
            json.put("message", "Joined community chat successfully");
            
            response.getWriter().print(json.toString());
            
        } catch (Exception e) {
            e.printStackTrace();
            sendError(response, "Error joining community chat: " + e.getMessage());
        }
    }
    
    private void markAsRead(HttpServletRequest request, int userId, HttpServletResponse response) throws Exception {
        try {
            String conversationIdParam = request.getParameter("conversationId");
            if (conversationIdParam == null || conversationIdParam.trim().isEmpty()) {
                sendError(response, "Conversation ID is required");
                return;
            }
            
            int conversationId = Integer.parseInt(conversationIdParam);
            messageDAO.markMessagesAsRead(conversationId, userId);
            
            JSONObject json = new JSONObject();
            json.put("success", true);
            response.getWriter().print(json.toString());
            
        } catch (NumberFormatException e) {
            sendError(response, "Invalid conversation ID format");
        } catch (Exception e) {
            e.printStackTrace();
            sendError(response, "Error marking messages as read: " + e.getMessage());
        }
    }
    
    // Helper methods for file handling
    private String getFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        if (contentDisp == null) {
            return "file";
        }
        
        String[] tokens = contentDisp.split(";");
        for (String token : tokens) {
            if (token.trim().startsWith("filename")) {
                return token.substring(token.indexOf("=") + 2, token.length() - 1);
            }
        }
        return "file";
    }
    
    private String saveUploadedFile(Part filePart, String fileName) throws IOException {
        String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads";
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) uploadDir.mkdirs();
        
        String filePath = uploadPath + File.separator + System.currentTimeMillis() + "_" + fileName;
        filePart.write(filePath);
        
        return "uploads/" + new File(filePath).getName();
    }
    
    private void sendError(HttpServletResponse response, String message) throws IOException {
        JSONObject json = new JSONObject();
        json.put("success", false);
        json.put("message", message);
        response.getWriter().print(json.toString());
    }
}