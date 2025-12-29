/**
 * MVC: View Layer (React)
 * Presentation logic - Renders UI based on model data
 */

import React, { useState } from 'react';
import { UserModel } from './model';

// Props interface
interface UserViewProps {
  users: UserModel[];
  onCreateUser: (name: string, email: string) => void;
  onUpdateUser: (id: string, name: string, email: string) => void;
  onDeleteUser: (id: string) => void;
  onSelectUser: (user: UserModel) => void;
  selectedUser?: UserModel;
}

// User List Component
export const UserListView: React.FC<{ users: UserModel[]; onSelectUser: (user: UserModel) => void }> = ({
  users,
  onSelectUser,
}) => {
  return (
    <div className="user-list">
      <h2>Users</h2>
      {users.length === 0 ? (
        <p>No users found</p>
      ) : (
        <ul>
          {users.map((user) => (
            <li key={user.getId()} onClick={() => onSelectUser(user)} style={{ cursor: 'pointer' }}>
              <strong>{user.getName()}</strong> - {user.getEmail()}
            </li>
          ))}
        </ul>
      )}
    </div>
  );
};

// User Form Component
interface UserFormProps {
  onSubmit: (name: string, email: string) => void;
  initialValues?: { name: string; email: string };
  buttonText?: string;
}

export const UserFormView: React.FC<UserFormProps> = ({ onSubmit, initialValues, buttonText = 'Create User' }) => {
  const [name, setName] = useState(initialValues?.name || '');
  const [email, setEmail] = useState(initialValues?.email || '');
  const [error, setError] = useState<string | null>(null);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();

    try {
      if (!name.trim()) {
        setError('Name is required');
        return;
      }
      if (!email.includes('@')) {
        setError('Invalid email format');
        return;
      }

      onSubmit(name, email);
      setName('');
      setEmail('');
      setError(null);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'An error occurred');
    }
  };

  return (
    <form onSubmit={handleSubmit} className="user-form">
      <h2>{buttonText}</h2>

      {error && <div className="error">{error}</div>}

      <div className="form-group">
        <label htmlFor="name">Name:</label>
        <input
          type="text"
          id="name"
          value={name}
          onChange={(e) => setName(e.target.value)}
          placeholder="Enter name"
        />
      </div>

      <div className="form-group">
        <label htmlFor="email">Email:</label>
        <input
          type="email"
          id="email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          placeholder="Enter email"
        />
      </div>

      <button type="submit">{buttonText}</button>
    </form>
  );
};

// User Detail Component
interface UserDetailProps {
  user: UserModel;
  onEdit: (name: string, email: string) => void;
  onDelete: () => void;
}

export const UserDetailView: React.FC<UserDetailProps> = ({ user, onEdit, onDelete }) => {
  const [isEditing, setIsEditing] = useState(false);

  if (isEditing) {
    return (
      <UserFormView
        initialValues={{
          name: user.getName(),
          email: user.getEmail(),
        }}
        onSubmit={(name, email) => {
          onEdit(name, email);
          setIsEditing(false);
        }}
        buttonText="Update User"
      />
    );
  }

  return (
    <div className="user-detail">
      <h2>User Details</h2>
      <p>
        <strong>ID:</strong> {user.getId()}
      </p>
      <p>
        <strong>Name:</strong> {user.getName()}
      </p>
      <p>
        <strong>Email:</strong> {user.getEmail()}
      </p>
      <p>
        <strong>Created:</strong> {user.getCreatedAt().toLocaleDateString()}
      </p>

      <div className="button-group">
        <button onClick={() => setIsEditing(true)}>Edit</button>
        <button onClick={onDelete} className="delete-btn">
          Delete
        </button>
      </div>
    </div>
  );
};

// Main Application View
export const AppView: React.FC<UserViewProps> = ({
  users,
  onCreateUser,
  onUpdateUser,
  onDeleteUser,
  onSelectUser,
  selectedUser,
}) => {
  return (
    <div className="app-container">
      <h1>User Management - MVC Pattern</h1>

      <div className="layout">
        <div className="sidebar">
          <UserListView users={users} onSelectUser={onSelectUser} />
          <UserFormView onSubmit={onCreateUser} />
        </div>

        <div className="main-content">
          {selectedUser ? (
            <UserDetailView
              user={selectedUser}
              onEdit={(name, email) => onUpdateUser(selectedUser.getId(), name, email)}
              onDelete={() => onDeleteUser(selectedUser.getId())}
            />
          ) : (
            <div className="empty-state">
              <p>Select a user or create a new one</p>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

// Styling suggestion
export const appStyles = `
  .app-container {
    max-width: 1200px;
    margin: 0 auto;
    padding: 20px;
    font-family: Arial, sans-serif;
  }

  .layout {
    display: flex;
    gap: 20px;
    margin-top: 20px;
  }

  .sidebar {
    flex: 0 0 300px;
    border-right: 1px solid #ccc;
    padding-right: 20px;
  }

  .main-content {
    flex: 1;
  }

  .user-list {
    margin-bottom: 20px;
  }

  .user-list ul {
    list-style: none;
    padding: 0;
  }

  .user-list li {
    padding: 10px;
    border: 1px solid #eee;
    margin-bottom: 5px;
    border-radius: 4px;
    transition: background-color 0.2s;
  }

  .user-list li:hover {
    background-color: #f5f5f5;
  }

  .user-form {
    border: 1px solid #ddd;
    padding: 15px;
    border-radius: 4px;
  }

  .form-group {
    margin-bottom: 15px;
  }

  .form-group label {
    display: block;
    margin-bottom: 5px;
    font-weight: bold;
  }

  .form-group input {
    width: 100%;
    padding: 8px;
    border: 1px solid #ddd;
    border-radius: 4px;
    font-size: 14px;
  }

  button {
    padding: 8px 16px;
    background-color: #007bff;
    color: white;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    font-size: 14px;
  }

  button:hover {
    background-color: #0056b3;
  }

  .delete-btn {
    background-color: #dc3545;
  }

  .delete-btn:hover {
    background-color: #c82333;
  }

  .error {
    color: #dc3545;
    padding: 10px;
    background-color: #f8d7da;
    border: 1px solid #f5c6cb;
    border-radius: 4px;
    margin-bottom: 15px;
  }

  .empty-state {
    padding: 40px;
    text-align: center;
    color: #666;
  }
`;
