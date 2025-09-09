<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.yash.tasktracker.model.User" %>
<%@ page import="com.yash.tasktracker.model.Task" %>
<%@ page import="com.yash.tasktracker.model.TaskPriority" %>
<%@ page import="com.yash.tasktracker.model.TaskStatus" %>
<%@ page import="java.util.List" %>

<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    List<Task> personalTasks = (List<Task>) request.getAttribute("personalTasks");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>TaskTracker - Dashboard</title>
    <link rel="stylesheet" href="style.css" />
    <style>
        .page-wrapper {
            display: flex;
            min-height: 100vh;
        }
        .sidebar {
            width: 250px;
            background: #2c3e50;
            color: white;
            padding: 20px;
            position: sticky;
            top: 0;
            min-height: 100vh;
        }
        .container {
            flex: 1;
            padding: 20px;
            background-color: #f8f9fa;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        .admin-title {
            font-size: 2.2rem;
            margin-bottom: 10px;
            color: #2c3e50;
            font-weight: 700;
        }
        .admin-subtitle {
            font-size: 1rem;
            margin-bottom: 25px;
            color: #6c757d;
        }
        .personal-tasks-section {
            width: 100%;
            margin: 25px 0;
            background: white;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
            overflow: hidden;
        }
        .section-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 20px 25px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        .section-header h3 { margin: 0; font-size: 1.4rem; font-weight: 600; }
        .add-task-btn {
            width: 40px;
            height: 40px;
            background: rgba(255, 255, 255, 0.2);
            border: 2px solid rgba(255, 255, 255, 0.3);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            transition: all 0.3s ease;
            font-size: 20px;
            font-weight: bold;
            color: white;
        }
        .add-task-btn:hover { background: rgba(255, 255, 255, 0.3); transform: scale(1.1); }

        .task-list { padding: 20px 0; max-height: 500px; overflow-y: auto; }
        .task-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 15px 25px;
            border-bottom: 1px solid #e9ecef;
            transition: background-color 0.2s ease;
        }
        .task-item:hover { background-color: #f8f9fa; }
        .task-details { flex: 1; }
        .task-title { font-weight: 600; color: #2c3e50; margin-bottom: 5px; font-size: 1.1rem; }
        .task-meta { display: flex; gap: 15px; font-size: 0.85rem; color: #6c757d; }
        .priority-badge { padding: 3px 8px; border-radius: 12px; font-size: 0.75rem; font-weight: 600; text-transform: uppercase; }
        .priority-low { background: #d1ecf1; color: #0c5460; }
        .priority-medium { background: #fff3cd; color: #856404; }
        .priority-high { background: #f8d7da; color: #721c24; }
        .priority-urgent { background: #f5c6cb; color: #491217; }
        .task-status { padding: 5px 12px; border-radius: 15px; font-size: 0.8rem; font-weight: 500; }
        .status-assigned, .status-pending { background: #fff3cd; color: #856404; }
        .status-in-progress { background: #cce5f0; color: #004085; }
        .status-completed { background: #d4edda; color: #155724; }
        .task-actions { display: flex; gap: 10px; }
        .task-actions a {
            padding: 6px 10px;
            font-size: 0.8rem;
            border-radius: 6px;
            text-decoration: none;
            background: #e9ecef;
            color: #2c3e50;
            transition: background 0.2s ease;
        }
        .task-actions a:hover { background: #ced4da; }

        .empty-state { text-align: center; padding: 40px 25px; color: #6c757d; }

        /* Modal Styles (for Create & Edit) */
        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0; top: 0;
            width: 100%; height: 100%;
            background-color: rgba(0,0,0,0.5);
            backdrop-filter: blur(5px);
        }
        .modal-content {
            background: white;
            margin: 5% auto;
            padding: 0;
            border-radius: 12px;
            width: 90%; max-width: 500px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.3);
            animation: modalSlideIn 0.3s ease-out;
        }
        @keyframes modalSlideIn {
            from { transform: translateY(-50px); opacity: 0; }
            to { transform: translateY(0); opacity: 1; }
        }
        .modal-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white; padding: 20px 25px;
            border-radius: 12px 12px 0 0;
            display: flex; justify-content: space-between;
        }
        .modal-body { padding: 25px; }
        .form-group { margin-bottom: 15px; }
        .form-group label { font-weight: 600; display: block; margin-bottom: 5px; }
        .form-group input, .form-group select, .form-group textarea {
            width: 100%; padding: 10px; border: 2px solid #e1e8ed;
            border-radius: 8px; font-size: 1rem;
        }
        .btn {
            padding: 12px; background: linear-gradient(135deg, #667eea, #764ba2);
            color: white; border: none; border-radius: 8px; width: 100%;
            font-weight: bold; cursor: pointer;
        }
    </style>
</head>
<body>
<div class="page-wrapper">
    <div class="sidebar">
        <jsp:include page="ManagerSidebar.jsp" />
    </div>

    <div class="container">
        <h1 class="admin-title">Welcome, <%= user.getFirstName() %>!</h1>
        <p class="admin-subtitle">Your role: <b><%= user.getRole() %></b></p>

        <div class="personal-tasks-section">
            <div class="section-header">
                <h3>My Personal Tasks</h3>
                <div class="add-task-btn" onclick="openCreateTaskModal()" title="Add New Task">+</div>
            </div>

            <div class="task-list">
                <%
                    if (personalTasks != null && !personalTasks.isEmpty()) {
                        for (Task t : personalTasks) {
                %>
                <div class="task-item">
                    <div class="task-details">
                        <div class="task-title"><%= t.getTitle() %></div>
                        <div class="task-meta">
                            <span class="priority-badge priority-<%= t.getPriority().name().toLowerCase() %>"><%= t.getPriority() %></span>
                            <span>Due: <%= t.getDeadline() != null ? t.getDeadline() : "No due date" %></span>
                            <span>Created: <%= t.getCreatedAt() %></span>
                        </div>
                    </div>
                    <div class="task-actions">
                        <a href="javascript:void(0)" onclick="openEditTaskModal('<%= t.getId() %>', '<%= t.getTitle() %>', '<%= t.getDescription() %>', '<%= t.getPriority() %>', '<%= t.getStatus() %>', '<%= t.getDeadline() != null ? new java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm").format(t.getDeadline()) : "" %>')">✏ Edit</a>
                        <a href="deletePersonalTask?id=<%= t.getId() %>" onclick="return confirm('Are you sure you want to delete this task?')">🗑 Delete</a>
                    </div>
                </div>
                <%      }
                    } else { %>
                <div class="empty-state">
                    <div style="font-size: 3rem; opacity: 0.5;">📋</div>
                    <h4>No personal tasks yet</h4>
                    <p>Click the + button above to create your first task!</p>
                </div>
                <% } %>
            </div>
        </div>
    </div>
</div>

<!-- CREATE TASK MODAL -->
<div id="createTaskModal" class="modal">
    <div class="modal-content">
        <div class="modal-header">
            <h3>Create Personal Task</h3>
            <span class="close" onclick="closeCreateTaskModal()">&times;</span>
        </div>
        <div class="modal-body">
            <form action="createPersonalTask" method="post" onsubmit="handleFormSubmit(event)">
                <div class="form-group"><label>Task Title:</label><input type="text" name="title" required></div>
                <div class="form-group"><label>Description:</label><textarea name="description"></textarea></div>
                <div class="form-group">
                    <label>Priority:</label>
                    <select name="priority" required>
                        <option value="">Select</option>
                        <option value="LOW">Low</option><option value="MEDIUM">Medium</option><option value="HIGH">High</option><option value="URGENT">Urgent</option>
                    </select>
                </div>
                <div class="form-group"><label>Due Date:</label><input type="datetime-local" name="dueDate" id="createDueDate"></div>
                <button type="submit" class="btn">Create Task</button>
            </form>
        </div>
    </div>
</div>

<!-- EDIT TASK MODAL -->
<div id="editTaskModal" class="modal">
    <div class="modal-content">
        <div class="modal-header">
            <h3>Edit Task</h3>
            <span class="close" onclick="closeEditTaskModal()">&times;</span>
        </div>
        <div class="modal-body">
            <form action="updatePersonalTask" method="post">
                <input type="hidden" name="id" id="editTaskId">
                <div class="form-group"><label>Task Title:</label><input type="text" name="title" id="editTaskTitle" required></div>
                <div class="form-group"><label>Description:</label><textarea name="description" id="editTaskDescription"></textarea></div>
                <div class="form-group">
                    <label>Priority:</label>
                    <select name="priority" id="editTaskPriority" required>
                        <option value="LOW">Low</option><option value="MEDIUM">Medium</option><option value="HIGH">High</option><option value="URGENT">Urgent</option>
                    </select>
                </div>
                <div class="form-group">
                    <label>Status:</label>
                    <select name="status" id="editTaskStatus">
                        <option value="ASSIGNED">Assigned</option><option value="IN_PROGRESS">In Progress</option><option value="COMPLETED">Completed</option><option value="DUE">Due</option>
                    </select>
                </div>
                <div class="form-group"><label>Due Date:</label><input type="datetime-local" name="dueDate" id="editTaskDueDate"></div>
                <button type="submit" class="btn">Update Task</button>
            </form>
        </div>
    </div>
</div>

<script>
    document.getElementById('createDueDate').min = new Date().toISOString().slice(0,16);

    function openCreateTaskModal() { document.getElementById('createTaskModal').style.display = 'block'; }
    function closeCreateTaskModal() { document.getElementById('createTaskModal').style.display = 'none'; }

    function openEditTaskModal(id, title, description, priority, status, deadline) {
        document.getElementById('editTaskId').value = id;
        document.getElementById('editTaskTitle').value = title;
        document.getElementById('editTaskDescription').value = description;
        document.getElementById('editTaskPriority').value = priority;
        document.getElementById('editTaskStatus').value = status;
        document.getElementById('editTaskDueDate').value = deadline;
        document.getElementById('editTaskModal').style.display = 'block';
    }
    function closeEditTaskModal() { document.getElementById('editTaskModal').style.display = 'none'; }

    window.onclick = function(event) {
        if (event.target.classList.contains('modal')) { closeCreateTaskModal(); closeEditTaskModal(); }
    }
</script>
</body>
</html>
