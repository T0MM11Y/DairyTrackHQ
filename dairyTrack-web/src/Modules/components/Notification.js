import React, { useState, useEffect, useCallback, useRef } from "react";
import {
  Dropdown,
  Modal,
  Button,
  Badge,
  Form,
  OverlayTrigger,
  Tooltip,
  FormControl,
  Card,
  Spinner,
} from "react-bootstrap";
import { useSocket } from "../../socket/socket";
import { formatDistanceToNow } from "date-fns";
import { deleteNotification } from "../controllers/notificationController";
import Swal from "sweetalert2";

const NotificationDropdown = () => {
  const {
    notifications,
    unreadCount,
    markAsRead,
    fetchNotifications,
    clearAllNotifications,
  } = useSocket();

  // State management
  const [isOpen, setIsOpen] = useState(false);
  const [showAllModal, setShowAllModal] = useState(false);
  const [loading, setLoading] = useState(false);
  const [currentUser, setCurrentUser] = useState(null);
  const [filteredNotifications, setFilteredNotifications] = useState([]);
  const [filter, setFilter] = useState("all");
  const [currentPage, setCurrentPage] = useState(1);
  const [searchTerm, setSearchTerm] = useState("");
  const [lastFetch, setLastFetch] = useState(0);

  // Refs to prevent multiple calls
  const fetchCooldownRef = useRef(false);
  const initializedRef = useRef(false);

  const notificationsPerPage = 8;
  const FETCH_COOLDOWN = 10000; // 10 seconds cooldown

  // Request notification permission - ONE TIME ONLY
  useEffect(() => {
    if (Notification.permission === "default") {
      Notification.requestPermission();
    }
  }, []);

  // Initialize user - ONE TIME ONLY
  useEffect(() => {
    if (!initializedRef.current) {
      const userData = JSON.parse(localStorage.getItem("user") || "{}");
      if (userData.user_id || userData.id) {
        const normalizedUser = {
          ...userData,
          user_id: userData.user_id || userData.id,
        };
        setCurrentUser(normalizedUser);
        console.log(
          "Notification component initialized with user:",
          normalizedUser
        );
        initializedRef.current = true;
      }
    }
  }, []);

  // Initial fetch when user is available - WITH COOLDOWN
  useEffect(() => {
    if (
      currentUser?.user_id &&
      fetchNotifications &&
      !fetchCooldownRef.current &&
      initializedRef.current
    ) {
      console.log("Initial notification fetch for user:", currentUser.user_id);
      fetchCooldownRef.current = true;
      setLastFetch(Date.now());

      fetchNotifications().finally(() => {
        // Release cooldown after 5 seconds
        setTimeout(() => {
          fetchCooldownRef.current = false;
        }, 5000);
      });
    }
  }, [currentUser?.user_id, fetchNotifications]);

  // Handle delete notification
  const handleDeleteNotification = useCallback(
    async (notificationId) => {
      const userId = currentUser?.user_id || currentUser?.id;
      if (!userId) {
        Swal.fire({
          icon: "error",
          title: "Error",
          text: "You must be logged in to delete notifications",
        });
        return;
      }

      try {
        const result = await Swal.fire({
          title: "Confirm Delete",
          text: "Are you sure you want to delete this notification?",
          icon: "warning",
          showCancelButton: true,
          confirmButtonColor: "#d33",
          cancelButtonColor: "#3085d6",
          confirmButtonText: "Delete",
          cancelButtonText: "Cancel",
        });

        if (result.isConfirmed) {
          const response = await deleteNotification(notificationId, userId);

          if (response.success) {
            Swal.fire({
              icon: "success",
              title: "Success",
              text: "Notification deleted successfully",
              timer: 1500,
              showConfirmButton: false,
            });

            // Only refresh if not in cooldown
            if (!fetchCooldownRef.current) {
              fetchCooldownRef.current = true;
              fetchNotifications().finally(() => {
                setTimeout(() => {
                  fetchCooldownRef.current = false;
                }, 3000);
              });
            }
          } else {
            Swal.fire({
              icon: "error",
              title: "Error",
              text: response.message || "Failed to delete notification",
            });
          }
        }
      } catch (error) {
        console.error("Error deleting notification:", error);
        Swal.fire({
          icon: "error",
          title: "Error",
          text: "An error occurred while deleting the notification",
        });
      }
    },
    [currentUser, fetchNotifications]
  );

  // Filter logic - STABLE CALLBACK
  const applyFilters = useCallback(() => {
    let filtered = [...notifications];
    if (searchTerm.trim()) {
      filtered = filtered.filter((n) =>
        n.message.toLowerCase().includes(searchTerm.toLowerCase())
      );
    }
    if (filter === "unread") {
      filtered = filtered.filter((n) => !n.is_read);
    } else if (filter === "low") {
      filtered = filtered.filter((n) => n.type === "low_production");
    } else if (filter === "high") {
      filtered = filtered.filter((n) => n.type === "high_production");
    }
    return filtered;
  }, [notifications, filter, searchTerm]);

  // Update filtered notifications - REMOVE applyFilters from dependencies
  useEffect(() => {
    setFilteredNotifications(applyFilters());
    setCurrentPage(1);
  }, [notifications, filter, searchTerm]); // Removed applyFilters dependency

  // Handle dropdown toggle with strict cooldown
  const handleToggle = useCallback(
    (open) => {
      setIsOpen(open);

      if (open) {
        const now = Date.now();
        const timeSinceLastFetch = now - lastFetch;

        // Only fetch if:
        // 1. No notifications OR
        // 2. Enough time has passed (10 seconds) AND
        // 3. Not currently in cooldown
        if (
          (!notifications.length || timeSinceLastFetch > FETCH_COOLDOWN) &&
          !fetchCooldownRef.current
        ) {
          console.log("Fetching notifications on dropdown open");
          fetchCooldownRef.current = true;
          setLoading(true);
          setLastFetch(now);

          fetchNotifications().finally(() => {
            setLoading(false);
            // Release cooldown after 3 seconds
            setTimeout(() => {
              fetchCooldownRef.current = false;
            }, 3000);
          });
        } else {
          console.log("Fetch skipped - cooldown active or recent fetch");
        }
      }
    },
    [fetchNotifications, notifications.length, lastFetch]
  );

  // Notification utility functions
  const getNotificationIcon = useCallback((type) => {
    switch (type) {
      case "milk_expiry":
        return "fas fa-exclamation-triangle";
      case "milk_warning":
        return "fas fa-clock";
      case "milk_used":
        return "fas fa-check-circle";
      case "low_production":
        return "fas fa-arrow-down";
      case "high_production":
        return "fas fa-arrow-up";
      default:
        return "fas fa-bell";
    }
  }, []);

  const getNotificationColor = useCallback((type) => {
    switch (type) {
      case "milk_used":
        return "success";
      default:
        return "primary";
    }
  }, []);

  const handleMarkAsRead = useCallback(
    (id, e) => {
      if (e) e.preventDefault();
      markAsRead(id);
    },
    [markAsRead]
  );

  const handleMarkAllAsRead = useCallback(() => {
    notifications.forEach((n) => {
      if (!n.is_read) markAsRead(n.id);
    });
  }, [notifications, markAsRead]);

  const formatTimeAgo = useCallback((dateString, dateStringWib) => {
    try {
      // Use created_at if available, otherwise fallback to created_at_wib
      const dateToUse = dateString || dateStringWib;
      if (!dateToUse) {
        return "Date unknown";
      }
      return formatDistanceToNow(new Date(dateToUse), { addSuffix: true });
    } catch {
      return "Date unknown";
    }
  }, []);

  // Pagination
  const indexOfLast = currentPage * notificationsPerPage;
  const indexOfFirst = indexOfLast - notificationsPerPage;
  const currentNotifications = filteredNotifications.slice(
    indexOfFirst,
    indexOfLast
  );
  const totalPages = Math.ceil(
    filteredNotifications.length / notificationsPerPage
  );

  const paginate = useCallback((pageNumber) => setCurrentPage(pageNumber), []);

  // Handle clear all notifications
  const handleClearAll = useCallback(async () => {
    const result = await Swal.fire({
      title: "Clear All Notifications?",
      text: "This action cannot be undone",
      icon: "warning",
      showCancelButton: true,
      confirmButtonColor: "#d33",
      cancelButtonColor: "#3085d6",
      confirmButtonText: "Yes, clear them",
      cancelButtonText: "Cancel",
    });

    if (result.isConfirmed && clearAllNotifications) {
      clearAllNotifications();
      setShowAllModal(false);
    }
  }, [clearAllNotifications]);

  return (
    <>
      <OverlayTrigger
        placement="bottom"
        overlay={
          <Tooltip id="notification-tooltip">
            {unreadCount
              ? `${unreadCount} new notification${unreadCount > 1 ? "s" : ""}`
              : "No new notifications"}
          </Tooltip>
        }
      >
        <Dropdown onToggle={handleToggle} show={isOpen} align="end">
          <Dropdown.Toggle
            variant="link"
            className="nav-link p-0 text-dark"
            id="notification-dropdown"
            style={{ outline: "none", boxShadow: "none" }}
          >
            <i
              className="fas fa-bell fa-lg"
              style={{
                color: unreadCount > 0 ? "#3D90D7" : "#adb5bd",
                transition: "color 0.2s",
              }}
            ></i>
            {unreadCount > 0 && (
              <span
                className="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger"
                style={{ fontSize: 10 }}
              >
                {unreadCount > 9 ? "9+" : unreadCount}
              </span>
            )}
          </Dropdown.Toggle>

          <Dropdown.Menu
            className="dropdown-menu-end shadow-sm border-0 p-0"
            style={{ minWidth: 320 }}
          >
            <div className="px-3 py-2 border-bottom d-flex align-items-center justify-content-between">
              <span
                className="fw-semibold"
                style={{
                  color: "#3D90D7",
                  fontFamily: "Roboto, sans-serif",
                  letterSpacing: "1px",
                }}
              >
                <i className="fas fa-bell me-2"></i>Notifications
              </span>
              {unreadCount > 0 && (
                <Badge bg="info" pill style={{ fontSize: 11 }}>
                  {unreadCount}
                </Badge>
              )}
            </div>

            {loading ? (
              <div className="text-center p-4">
                <Spinner animation="border" size="sm" variant="primary" />
                <div className="text-muted small mt-2">Loading...</div>
              </div>
            ) : (
              <div style={{ maxHeight: 320, overflowY: "auto" }}>
                {notifications.length === 0 ? (
                  <div className="text-center text-muted py-4">
                    <i className="fas fa-bell-slash fa-2x mb-2"></i>
                    <div>No notifications</div>
                  </div>
                ) : (
                  notifications.slice(0, 5).map((n) => (
                    <div
                      key={n.id}
                      className={`d-flex align-items-start px-3 py-2 border-bottom ${
                        !n.is_read ? "bg-light" : ""
                      }`}
                      style={{ cursor: "pointer" }}
                    >
                      <div
                        className="d-flex flex-grow-1 align-items-start"
                        onClick={(e) => handleMarkAsRead(n.id, e)}
                      >
                        <div className="me-2">
                          <span
                            className={`d-inline-flex align-items-center justify-content-center rounded-circle ${
                              n.type === "low_production"
                                ? "bg-danger bg-opacity-10"
                                : n.type === "high_production"
                                ? "bg-success bg-opacity-10"
                                : "bg-secondary bg-opacity-10"
                            }`}
                            style={{ width: 32, height: 32 }}
                          >
                            <i
                              className={`${getNotificationIcon(n.type)} ${
                                n.type === "low_production"
                                  ? "text-danger"
                                  : n.type === "high_production"
                                  ? "text-success"
                                  : "text-secondary"
                              }`}
                            ></i>
                          </span>
                        </div>
                        <div className="flex-grow-1">
                          <div className="d-flex justify-content-between align-items-center">
                            <span className="small text-muted">
                              {formatTimeAgo(n.created_at, n.created_at_wib)}
                            </span>
                            {!n.is_read && (
                              <Badge bg="primary" pill style={{ fontSize: 9 }}>
                                New
                              </Badge>
                            )}
                          </div>
                          <div className="small">{n.message}</div>
                        </div>
                      </div>
                      <Button
                        variant="outline-danger"
                        size="sm"
                        className="ms-2 align-self-center"
                        style={{ padding: "0.25rem 0.5rem" }}
                        onClick={(e) => {
                          e.stopPropagation();
                          handleDeleteNotification(n.id);
                        }}
                      >
                        <i className="fas fa-trash-alt"></i>
                      </Button>
                    </div>
                  ))
                )}
              </div>
            )}

            <div className="px-3 py-2 border-top d-flex gap-2">
              {unreadCount > 0 && (
                <Button
                  variant="outline-primary"
                  size="sm"
                  className="flex-grow-1"
                  onClick={handleMarkAllAsRead}
                >
                  Mark all read
                </Button>
              )}
              <Button
                variant="primary"
                size="sm"
                className="flex-grow-1"
                onClick={() => {
                  setShowAllModal(true);
                  setIsOpen(false);
                }}
              >
                View all
              </Button>
            </div>
          </Dropdown.Menu>
        </Dropdown>
      </OverlayTrigger>

      {/* Modal for all notifications */}
      <Modal
        show={showAllModal}
        onHide={() => setShowAllModal(false)}
        size="md"
        centered
      >
        <Modal.Header closeButton>
          <Modal.Title
            style={{
              fontFamily: "Roboto, sans-serif",
              letterSpacing: "1px",
              fontSize: 18,
              fontWeight: 700,
              color: "#3D90D7",
            }}
          >
            <i className="fas fa-bell me-2"></i>Notifications
          </Modal.Title>
        </Modal.Header>
        <Modal.Body>
          <div className="d-flex mb-3 gap-2">
            <Button
              variant={filter === "all" ? "primary" : "outline-primary"}
              size="sm"
              onClick={() => setFilter("all")}
            >
              All
            </Button>
            <Button
              variant={filter === "unread" ? "primary" : "outline-primary"}
              size="sm"
              onClick={() => setFilter("unread")}
            >
              Unread
            </Button>
            <Button
              variant={filter === "low" ? "danger" : "outline-danger"}
              size="sm"
              onClick={() => setFilter("low")}
            >
              Low
            </Button>
            <Button
              variant={filter === "high" ? "success" : "outline-success"}
              size="sm"
              onClick={() => setFilter("high")}
            >
              High
            </Button>
            <FormControl
              size="sm"
              placeholder="Search..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              style={{ maxWidth: 140, marginLeft: "auto" }}
            />
          </div>

          {currentNotifications.length === 0 ? (
            <div className="text-center text-muted py-4">
              <i className="fas fa-bell-slash fa-2x mb-2"></i>
              <div>No notifications found</div>
            </div>
          ) : (
            <div style={{ maxHeight: 350, overflowY: "auto" }}>
              {currentNotifications.map((n) => (
                <Card
                  key={n.id}
                  className={`mb-2 border-0 ${!n.is_read ? "bg-light" : ""}`}
                  style={{ boxShadow: "0 1px 2px rgba(0,0,0,0.03)" }}
                >
                  <Card.Body className="py-2 px-3 d-flex align-items-center">
                    <span
                      className={`d-inline-flex align-items-center justify-content-center rounded-circle me-2 ${
                        n.type === "low_production"
                          ? "bg-danger bg-opacity-10"
                          : n.type === "high_production"
                          ? "bg-success bg-opacity-10"
                          : "bg-secondary bg-opacity-10"
                      }`}
                      style={{ width: 28, height: 28 }}
                    >
                      <i
                        className={`${getNotificationIcon(n.type)} ${
                          n.type === "low_production"
                            ? "text-danger"
                            : n.type === "high_production"
                            ? "text-success"
                            : "text-secondary"
                        }`}
                      ></i>
                    </span>
                    <div className="flex-grow-1">
                      <div className="d-flex justify-content-between align-items-center">
                        <span className="small text-muted">
                          {formatTimeAgo(n.created_at, n.created_at_wib)}
                        </span>
                        {!n.is_read ? (
                          <Button
                            variant="link"
                            size="sm"
                            className="p-0 text-primary"
                            style={{ fontSize: 13 }}
                            onClick={() => markAsRead(n.id)}
                          >
                            Mark as read
                          </Button>
                        ) : (
                          <span className="small text-secondary">Read</span>
                        )}
                      </div>
                      <div className="small">{n.message}</div>
                    </div>
                    <Button
                      variant="outline-danger"
                      size="sm"
                      className="ms-2"
                      style={{ padding: "0.25rem 0.5rem" }}
                      onClick={() => handleDeleteNotification(n.id)}
                    >
                      <i className="fas fa-trash-alt"></i>
                    </Button>
                  </Card.Body>
                </Card>
              ))}
            </div>
          )}

          {/* Pagination */}
          {totalPages > 1 && (
            <div className="d-flex justify-content-center mt-3">
              <nav>
                <ul className="pagination pagination-sm mb-0">
                  <li
                    className={`page-item ${
                      currentPage === 1 ? "disabled" : ""
                    }`}
                  >
                    <button className="page-link" onClick={() => paginate(1)}>
                      &laquo;
                    </button>
                  </li>
                  <li
                    className={`page-item ${
                      currentPage === 1 ? "disabled" : ""
                    }`}
                  >
                    <button
                      className="page-link"
                      onClick={() => paginate(currentPage - 1)}
                    >
                      &lsaquo;
                    </button>
                  </li>
                  {[...Array(totalPages)].map((_, i) => (
                    <li
                      key={i}
                      className={`page-item ${
                        currentPage === i + 1 ? "active" : ""
                      }`}
                    >
                      <button
                        className="page-link"
                        onClick={() => paginate(i + 1)}
                      >
                        {i + 1}
                      </button>
                    </li>
                  ))}
                  <li
                    className={`page-item ${
                      currentPage === totalPages ? "disabled" : ""
                    }`}
                  >
                    <button
                      className="page-link"
                      onClick={() => paginate(currentPage + 1)}
                    >
                      &rsaquo;
                    </button>
                  </li>
                  <li
                    className={`page-item ${
                      currentPage === totalPages ? "disabled" : ""
                    }`}
                  >
                    <button
                      className="page-link"
                      onClick={() => paginate(totalPages)}
                    >
                      &raquo;
                    </button>
                  </li>
                </ul>
              </nav>
            </div>
          )}
        </Modal.Body>
        <Modal.Footer className="d-flex justify-content-between">
          <Button variant="outline-danger" onClick={handleClearAll}>
            Clear all
          </Button>
          <Button variant="primary" onClick={() => setShowAllModal(false)}>
            Close
          </Button>
        </Modal.Footer>
      </Modal>
    </>
  );
};

export default NotificationDropdown;
