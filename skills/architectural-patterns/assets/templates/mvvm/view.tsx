/**
 * MVVM: View Layer (React)
 * Pure presentation logic - Binds to ViewModel observables
 * No business logic - Only displays data
 */

import React, { useState, useEffect } from 'react';
import { UserViewModel } from './viewmodel';
import { UserModel } from './model';

interface UserViewProps {
  viewModel: UserViewModel;
}

/**
 * Custom Hook for Observable binding
 */
function useObservable<T>(observable: any, initialValue: T): T {
  const [value, setValue] = useState<T>(initialValue);

  useEffect(() => {
    // Subscribe to observable
    const unsubscribe = observable.subscribe((newValue: T) => {
      setValue(newValue);
    });

    // Initial value
    setValue(observable.getValue());

    // Cleanup
    return unsubscribe;
  }, [observable]);

  return value;
}

/**
 * Main Application View
 */
export const MvvmAppView: React.FC<UserViewProps> = ({ viewModel }) => {
  const users = useObservable(viewModel.users$, []);
  const selectedUser = useObservable(viewModel.selectedUser$, null);
  const isLoading = useObservable(viewModel.isLoading$, false);

  useEffect(() => {
    viewModel.loadUsers();
  }, [viewModel]);

  return (
    <div className="mvvm-app">
      <h1>User Management - MVVM Pattern</h1>

      <div className="mvvm-layout">
        <div className="mvvm-sidebar">
          <UserListViewMvvm viewModel={viewModel} users={users} selectedUser={selectedUser} />
          <UserFormViewMvvm viewModel={viewModel} />
        </div>

        <div className="mvvm-main">
          {selectedUser ? (
            <UserDetailViewMvvm user={selectedUser} viewModel={viewModel} />
          ) : (
            <div className="empty-state">
              <p>Select a user or create a new one</p>
            </div>
          )}
        </div>
      </div>

      {isLoading && <div className="loading">Loading...</div>}
    </div>
  );
};

/**
 * User List Component
 * Binds to users$ observable
 */
interface UserListProps {
  viewModel: UserViewModel;
  users: UserModel[];
  selectedUser: UserModel | null;
}

const UserListViewMvvm: React.FC<UserListProps> = ({ viewModel, users, selectedUser }) => {
  return (
    <div className="user-list-mvvm">
      <h2>Users</h2>
      {users.length === 0 ? (
        <p className="no-users">No users yet</p>
      ) : (
        <ul>
          {users.map((user) => (
            <li
              key={user.id}
              className={selectedUser?.id === user.id ? 'selected' : ''}
              onClick={() => viewModel.selectUser(user)}
            >
              <strong>{user.name}</strong>
              <small>{user.email}</small>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
};

/**
 * User Form Component
 * Two-way binding with ViewModel
 */
const UserFormViewMvvm: React.FC<{ viewModel: UserViewModel }> = ({ viewModel }) => {
  const name = useObservable(viewModel.formName$, '');
  const email = useObservable(viewModel.formEmail$, '');
  const error = useObservable(viewModel.error$, null);
  const isSelected = viewModel.isUserSelected;

  return (
    <div className="user-form-mvvm">
      <h2>{isSelected ? 'Edit User' : 'New User'}</h2>

      {error && <div className="error-message">{error}</div>}

      <div className="form-group-mvvm">
        <label htmlFor="name">Name</label>
        <input
          type="text"
          id="name"
          value={name}
          onChange={(e) => viewModel.formName$.setValue(e.target.value)}
          placeholder="Enter name"
          disabled={viewModel.isLoading$.getValue()}
        />
      </div>

      <div className="form-group-mvvm">
        <label htmlFor="email">Email</label>
        <input
          type="email"
          id="email"
          value={email}
          onChange={(e) => viewModel.formEmail$.setValue(e.target.value)}
          placeholder="Enter email"
          disabled={viewModel.isLoading$.getValue()}
        />
      </div>

      <div className="button-group-mvvm">
        {isSelected ? (
          <>
            <button onClick={() => viewModel.updateSelectedUser()} disabled={!viewModel.canSave}>
              Update
            </button>
            <button onClick={() => viewModel.clearForm()} className="secondary">
              Cancel
            </button>
          </>
        ) : (
          <>
            <button onClick={() => viewModel.createUser()} disabled={!viewModel.canSave}>
              Create
            </button>
            <button onClick={() => viewModel.clearForm()} className="secondary">
              Clear
            </button>
          </>
        )}
      </div>
    </div>
  );
};

/**
 * User Detail Component
 */
interface UserDetailProps {
  user: UserModel;
  viewModel: UserViewModel;
}

const UserDetailViewMvvm: React.FC<UserDetailProps> = ({ user, viewModel }) => {
  return (
    <div className="user-detail-mvvm">
      <h2>User Details</h2>
      <div className="detail-field">
        <label>ID:</label>
        <span>{user.id}</span>
      </div>
      <div className="detail-field">
        <label>Name:</label>
        <span>{user.name}</span>
      </div>
      <div className="detail-field">
        <label>Email:</label>
        <span>{user.email}</span>
      </div>
      <div className="detail-field">
        <label>Created:</label>
        <span>{user.createdAt.toLocaleDateString()}</span>
      </div>

      <div className="action-buttons">
        <button onClick={() => viewModel.deleteSelectedUser()} className="danger">
          Delete User
        </button>
      </div>
    </div>
  );
};

/**
 * Styling
 */
export const mvvmStyles = `
  .mvvm-app {
    max-width: 1200px;
    margin: 0 auto;
    padding: 20px;
    font-family: Arial, sans-serif;
  }

  .mvvm-layout {
    display: flex;
    gap: 20px;
    margin-top: 20px;
  }

  .mvvm-sidebar {
    flex: 0 0 350px;
    display: flex;
    flex-direction: column;
    gap: 20px;
  }

  .mvvm-main {
    flex: 1;
  }

  .user-list-mvvm,
  .user-form-mvvm {
    border: 1px solid #ddd;
    padding: 15px;
    border-radius: 4px;
  }

  .user-list-mvvm ul {
    list-style: none;
    padding: 0;
    margin: 0;
  }

  .user-list-mvvm li {
    padding: 10px;
    border: 1px solid #eee;
    margin-bottom: 5px;
    border-radius: 4px;
    cursor: pointer;
    transition: all 0.2s;
  }

  .user-list-mvvm li:hover {
    background-color: #f5f5f5;
  }

  .user-list-mvvm li.selected {
    background-color: #e3f2fd;
    border-color: #2196f3;
  }

  .user-list-mvvm li small {
    display: block;
    font-size: 12px;
    color: #666;
    margin-top: 5px;
  }

  .form-group-mvvm {
    margin-bottom: 15px;
  }

  .form-group-mvvm label {
    display: block;
    margin-bottom: 5px;
    font-weight: bold;
  }

  .form-group-mvvm input {
    width: 100%;
    padding: 8px;
    border: 1px solid #ddd;
    border-radius: 4px;
    font-size: 14px;
  }

  .button-group-mvvm {
    display: flex;
    gap: 10px;
  }

  button {
    padding: 8px 16px;
    background-color: #2196f3;
    color: white;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    font-size: 14px;
  }

  button:hover:not(:disabled) {
    background-color: #1976d2;
  }

  button:disabled {
    opacity: 0.5;
    cursor: not-allowed;
  }

  button.secondary {
    background-color: #999;
  }

  button.danger {
    background-color: #dc3545;
  }

  .error-message {
    color: #d32f2f;
    padding: 10px;
    background-color: #ffebee;
    border: 1px solid #ef5350;
    border-radius: 4px;
    margin-bottom: 15px;
  }

  .user-detail-mvvm {
    border: 1px solid #ddd;
    padding: 20px;
    border-radius: 4px;
  }

  .detail-field {
    margin-bottom: 15px;
  }

  .detail-field label {
    display: block;
    font-weight: bold;
    margin-bottom: 5px;
    color: #666;
  }

  .detail-field span {
    display: block;
    padding: 10px;
    background-color: #f5f5f5;
    border-radius: 4px;
  }

  .action-buttons {
    display: flex;
    gap: 10px;
    margin-top: 20px;
  }

  .loading {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background-color: rgba(0, 0, 0, 0.5);
    display: flex;
    align-items: center;
    justify-content: center;
    color: white;
    font-size: 24px;
  }
`;
