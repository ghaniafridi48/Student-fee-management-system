"""
============================================================================
STUDENT FEE MANAGEMENT SYSTEM (SFMS)
Desktop Application - Python Tkinter + MySQL
============================================================================
Author: Muhammad Aimal khan & Muhammad Ghani
Course: Database Systems Lab
Program: BS Computer Science
============================================================================
"""

import tkinter as tk
from tkinter import ttk, messagebox, scrolledtext
from tkinter.font import Font
import mysql.connector
from mysql.connector import Error
from datetime import datetime, date
import random
import os

# ============================================================
# DATABASE CONFIGURATION
# ============================================================
DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': 'password123',  # CHANGE THIS TO YOUR MySQL PASSWORD
    'database': 'sfms_db'
}

# ============================================================
# SCROLLABLE FRAME CLASS (Proper Working Implementation)
# ============================================================
class ScrollableFrame(tk.Frame):
    """A frame that contains a canvas and scrollbar for scrolling content"""

    def __init__(self, parent, bg_color="#f0f2f5", *args, **kwargs):
        super().__init__(parent, *args, **kwargs)

        self.canvas = tk.Canvas(self, bg=bg_color, highlightthickness=0)
        self.scrollbar = ttk.Scrollbar(self, orient="vertical", command=self.canvas.yview)
        self.scrollable_frame = tk.Frame(self.canvas, bg=bg_color)

        # Update scrollregion when inner frame changes size
        self.scrollable_frame.bind(
            "<Configure>",
            lambda e: self.canvas.configure(scrollregion=self.canvas.bbox("all"))
        )

        # Place scrollable frame inside canvas
        self.canvas_window = self.canvas.create_window((0, 0), window=self.scrollable_frame, anchor="nw")

        # Connect scrollbar to canvas
        self.canvas.configure(yscrollcommand=self.scrollbar.set)

        # Pack canvas and scrollbar
        self.canvas.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        self.scrollbar.pack(side=tk.RIGHT, fill=tk.Y)

        # Mouse wheel support
        self.canvas.bind("<Enter>", self._bind_mousewheel)
        self.canvas.bind("<Leave>", self._unbind_mousewheel)

        # Resize inner frame to match canvas width
        self.canvas.bind("<Configure>", self._on_canvas_configure)

    def _on_canvas_configure(self, event):
        """Make inner frame match canvas width"""
        self.canvas.itemconfig(self.canvas_window, width=event.width)

    def _on_mousewheel(self, event):
        self.canvas.yview_scroll(int(-1 * (event.delta / 120)), "units")

    def _bind_mousewheel(self, event=None):
        self.canvas.bind_all("<MouseWheel>", self._on_mousewheel)

    def _unbind_mousewheel(self, event=None):
        self.canvas.unbind_all("<MouseWheel>")


# ============================================================
# DATABASE CONNECTION CLASS
# ============================================================
class DatabaseConnection:
    """Handles all database operations for SFMS"""

    def __init__(self):
        self.connection = None
        self.cursor = None

    def connect(self):
        """Establish database connection"""
        try:
            self.connection = mysql.connector.connect(**DB_CONFIG)
            self.cursor = self.connection.cursor(dictionary=True)
            return True
        except Error as e:
            messagebox.showerror("Database Error", f"Failed to connect to database:\n{e}\n\nPlease check your MySQL credentials in DB_CONFIG.")
            return False

    def disconnect(self):
        """Close database connection"""
        if self.cursor:
            self.cursor.close()
        if self.connection:
            self.connection.close()

    def execute_query(self, query, params=None):
        """Execute a SELECT query and return results"""
        try:
            if params:
                self.cursor.execute(query, params)
            else:
                self.cursor.execute(query)
            return self.cursor.fetchall()
        except Error as e:
            messagebox.showerror("Query Error", str(e))
            return None

    def execute_non_query(self, query, params=None):
        """Execute INSERT, UPDATE, DELETE queries"""
        try:
            if params:
                self.cursor.execute(query, params)
            else:
                self.cursor.execute(query)
            self.connection.commit()
            return True
        except Error as e:
            self.connection.rollback()
            messagebox.showerror("Query Error", str(e))
            return False

    def get_last_insert_id(self):
        """Get the ID of the last inserted row"""
        return self.cursor.lastrowid


# ============================================================
# MAIN APPLICATION CLASS
# ============================================================
class SFMSApp:
    """Main Student Fee Management System Application"""

    def __init__(self, root):
        self.root = root
        self.root.title("Student Fee Management System (SFMS)")
        self.root.geometry("1400x800")
        self.root.configure(bg="#f0f2f5")

        # Set window icon (optional)
        try:
            self.root.iconbitmap("sfms_icon.ico")
        except:
            pass

        # Initialize database
        self.db = DatabaseConnection()
        if not self.db.connect():
            self.root.destroy()
            return

        # Create UI
        self.create_styles()
        self.create_header()
        self.create_sidebar()
        self.create_main_content()
        self.show_dashboard()

        # Bind window close event
        self.root.protocol("WM_DELETE_WINDOW", self.on_closing)

    def create_styles(self):
        """Configure ttk styles"""
        self.style = ttk.Style()
        self.style.theme_use('clam')

        # Colors
        self.PRIMARY_COLOR = "#2c3e50"
        self.SECONDARY_COLOR = "#3498db"
        self.ACCENT_COLOR = "#e74c3c"
        self.SUCCESS_COLOR = "#27ae60"
        self.BG_COLOR = "#f0f2f5"
        self.CARD_BG = "#ffffff"

        # Button styles
        self.style.configure("Primary.TButton",
                            font=("Segoe UI", 11, "bold"),
                            foreground="white",
                            background=self.SECONDARY_COLOR,
                            padding=(15, 8))

        self.style.configure("Danger.TButton",
                            font=("Segoe UI", 11, "bold"),
                            foreground="white",
                            background=self.ACCENT_COLOR,
                            padding=(15, 8))

        self.style.configure("Success.TButton",
                            font=("Segoe UI", 11, "bold"),
                            foreground="white",
                            background=self.SUCCESS_COLOR,
                            padding=(15, 8))

        # Treeview style
        self.style.configure("Custom.Treeview",
                            font=("Segoe UI", 10),
                            rowheight=30,
                            background=self.CARD_BG,
                            fieldbackground=self.CARD_BG)
        self.style.configure("Custom.Treeview.Heading",
                            font=("Segoe UI", 11, "bold"),
                            background=self.PRIMARY_COLOR,
                            foreground="white")

        # Label styles
        self.style.configure("Title.TLabel",
                            font=("Segoe UI", 24, "bold"),
                            foreground=self.PRIMARY_COLOR,
                            background=self.BG_COLOR)

        self.style.configure("Subtitle.TLabel",
                            font=("Segoe UI", 14),
                            foreground="#7f8c8d",
                            background=self.BG_COLOR)

        self.style.configure("CardTitle.TLabel",
                            font=("Segoe UI", 16, "bold"),
                            foreground=self.PRIMARY_COLOR,
                            background=self.CARD_BG)

    def create_header(self):
        """Create application header"""
        self.header = tk.Frame(self.root, bg=self.PRIMARY_COLOR, height=70)
        self.header.pack(fill=tk.X)
        self.header.pack_propagate(False)

        # Title
        title_label = tk.Label(self.header,
                               text="📚 Student Fee Management System",
                               font=("Segoe UI", 20, "bold"),
                               fg="white",
                               bg=self.PRIMARY_COLOR)
        title_label.pack(side=tk.LEFT, padx=20, pady=10)

        # Date/Time
        self.datetime_label = tk.Label(self.header,
                                       text=datetime.now().strftime("%A, %B %d, %Y | %I:%M %p"),
                                       font=("Segoe UI", 11),
                                       fg="#bdc3c7",
                                       bg=self.PRIMARY_COLOR)
        self.datetime_label.pack(side=tk.RIGHT, padx=20, pady=10)

        # Update clock
        self.update_clock()

    def update_clock(self):
        """Update the clock label every second"""
        self.datetime_label.config(text=datetime.now().strftime("%A, %B %d, %Y | %I:%M:%S %p"))
        self.root.after(1000, self.update_clock)

    def create_sidebar(self):
        """Create navigation sidebar"""
        self.sidebar = tk.Frame(self.root, bg=self.PRIMARY_COLOR, width=250)
        self.sidebar.pack(side=tk.LEFT, fill=tk.Y)
        self.sidebar.pack_propagate(False)

        # Menu items
        menu_items = [
            ("🏠 Dashboard", self.show_dashboard),
            ("👨‍🎓 Students", self.show_students),
            ("💰 Payments", self.show_payments),
            ("📋 Fee Structure", self.show_fee_structure),
            ("📊 Reports", self.show_reports),
            ("🔍 Search", self.show_search),
        ]

        # Welcome text
        welcome_label = tk.Label(self.sidebar,
                                 text="Welcome, Admin",
                                 font=("Segoe UI", 12, "bold"),
                                 fg="white",
                                 bg=self.PRIMARY_COLOR)
        welcome_label.pack(pady=(20, 10), padx=15)

        # Separator
        tk.Frame(self.sidebar, bg="#34495e", height=2).pack(fill=tk.X, padx=15, pady=5)

        # Menu buttons
        self.menu_buttons = []
        for text, command in menu_items:
            btn = tk.Button(self.sidebar,
                            text=text,
                            font=("Segoe UI", 12),
                            fg="white",
                            bg=self.PRIMARY_COLOR,
                            activebackground=self.SECONDARY_COLOR,
                            activeforeground="white",
                            bd=0,
                            padx=20,
                            pady=12,
                            anchor=tk.W,
                            width=25,
                            cursor="hand2",
                            command=command)
            btn.pack(fill=tk.X, padx=5, pady=2)
            self.menu_buttons.append(btn)

        # Separator before exit
        tk.Frame(self.sidebar, bg="#34495e", height=2).pack(fill=tk.X, padx=15, pady=10)

        # Exit button
        exit_btn = tk.Button(self.sidebar,
                             text="🚪 Exit",
                             font=("Segoe UI", 12),
                             fg="#e74c3c",
                             bg=self.PRIMARY_COLOR,
                             activebackground="#c0392b",
                             activeforeground="white",
                             bd=0,
                            padx=20,
                            pady=12,
                            anchor=tk.W,
                            width=25,
                            cursor="hand2",
                            command=self.on_closing)
        exit_btn.pack(fill=tk.X, padx=5, pady=2)

    def create_main_content(self):
        """Create main content area"""
        self.main_frame = tk.Frame(self.root, bg=self.BG_COLOR)
        self.main_frame.pack(side=tk.LEFT, fill=tk.BOTH, expand=True, padx=20, pady=20)

    def clear_main_content(self):
        """Clear all widgets from main content area"""
        for widget in self.main_frame.winfo_children():
            widget.destroy()

    # ============================================================
    # HELPER: Create a Treeview with visible vertical AND horizontal scrollbars
    # ============================================================
    def create_tree_with_scrollbars(self, parent, columns, col_widths=None, height=15):
        """
        Creates a Treeview inside a frame with thick, visible tk.Scrollbars
        (both vertical and horizontal) so nothing is cut off.
        Returns the Treeview widget.
        """
        container = tk.Frame(parent, bg=self.BG_COLOR)
        container.pack(fill=tk.BOTH, expand=True)

        # Treeview
        tree = ttk.Treeview(container, columns=columns, show="headings",
                            height=height, style="Custom.Treeview")

        # Column widths
        if col_widths:
            for col in columns:
                tree.heading(col, text=col)
                tree.column(col, width=col_widths.get(col, 130), anchor=tk.CENTER, minwidth=80)
        else:
            for col in columns:
                tree.heading(col, text=col)
                tree.column(col, width=130, anchor=tk.CENTER, minwidth=80)

        # --- VISIBLE VERTICAL SCROLLBAR ---
        vsb = tk.Scrollbar(container, orient="vertical", command=tree.yview,
                           width=16, troughcolor=self.BG_COLOR, bg="#bdc3c7",
                           activebackground="#95a5a6", highlightthickness=0, bd=0)
        tree.configure(yscrollcommand=vsb.set)

        # --- VISIBLE HORIZONTAL SCROLLBAR ---
        hsb = tk.Scrollbar(container, orient="horizontal", command=tree.xview,
                           width=16, troughcolor=self.BG_COLOR, bg="#bdc3c7",
                           activebackground="#95a5a6", highlightthickness=0, bd=0)
        tree.configure(xscrollcommand=hsb.set)

        # Grid layout so both scrollbars fit nicely
        tree.grid(row=0, column=0, sticky="nsew")
        vsb.grid(row=0, column=1, sticky="ns")
        hsb.grid(row=1, column=0, sticky="ew")

        container.grid_rowconfigure(0, weight=1)
        container.grid_columnconfigure(0, weight=1)

        return tree

    # ============================================================
    # DASHBOARD SECTION
    # ============================================================
    def show_dashboard(self):
        """Display the dashboard with summary cards"""
        self.clear_main_content()

        # Title
        tk.Label(self.main_frame,
                 text="Dashboard",
                 font=("Segoe UI", 28, "bold"),
                 fg=self.PRIMARY_COLOR,
                 bg=self.BG_COLOR).pack(anchor=tk.W, pady=(0, 20))

        # Fetch statistics
        stats = self.get_dashboard_stats()

        # Stats cards frame
        cards_frame = tk.Frame(self.main_frame, bg=self.BG_COLOR)
        cards_frame.pack(fill=tk.X, pady=10)

        # Card data
        cards = [
            ("👨‍🎓 Total Students", stats['total_students'], "#3498db"),
            ("💰 Total Collected", f"Rs. {stats['total_collected']:,.2f}", "#27ae60"),
            ("📋 Total Pending", f"Rs. {stats['total_pending']:,.2f}", "#e74c3c"),
            ("📊 Departments", stats['total_departments'], "#9b59b6"),
        ]

        for title, value, color in cards:
            card = tk.Frame(cards_frame, bg=self.CARD_BG, bd=0, relief=tk.RAISED)
            card.pack(side=tk.LEFT, fill=tk.BOTH, expand=True, padx=10, pady=5)
            card.configure(highlightbackground=color, highlightthickness=2)

            tk.Label(card, text=title, font=("Segoe UI", 12),
                     fg="#7f8c8d", bg=self.CARD_BG).pack(pady=(15, 5))
            tk.Label(card, text=str(value), font=("Segoe UI", 24, "bold"),
                     fg=color, bg=self.CARD_BG).pack(pady=(0, 15))

        # Recent Payments Section
        tk.Label(self.main_frame,
                 text="Recent Payments",
                 font=("Segoe UI", 18, "bold"),
                 fg=self.PRIMARY_COLOR,
                 bg=self.BG_COLOR).pack(anchor=tk.W, pady=(30, 10))

        columns = ("Receipt No", "Student", "Amount", "Date", "Method")
        col_widths = {"Receipt No": 150, "Student": 200, "Amount": 120, "Date": 120, "Method": 120}
        tree = self.create_tree_with_scrollbars(self.main_frame, columns, col_widths, height=8)

        # Fetch recent payments
        recent_payments = self.db.execute_query("""
            SELECT r.receipt_no, s.name, p.amount, p.payment_date, p.payment_method
            FROM payment p
            JOIN student s ON p.student_id = s.student_id
            LEFT JOIN receipt r ON p.payment_id = r.payment_id
            ORDER BY p.payment_date DESC
            LIMIT 10
        """)

        if recent_payments:
            for payment in recent_payments:
                tree.insert("", tk.END, values=(
                    payment['receipt_no'] or "N/A",
                    payment['name'],
                    f"Rs. {payment['amount']:,.2f}",
                    payment['payment_date'].strftime("%Y-%m-%d") if payment['payment_date'] else "N/A",
                    payment['payment_method']
                ))

    def get_dashboard_stats(self):
        """Get dashboard statistics"""
        stats = {'total_students': 0, 'total_collected': 0, 'total_pending': 0, 'total_departments': 0}

        result = self.db.execute_query("SELECT COUNT(*) as count FROM student WHERE status='Active'")
        if result:
            stats['total_students'] = result[0]['count']

        result = self.db.execute_query("SELECT COALESCE(SUM(amount), 0) as total FROM payment")
        if result:
            stats['total_collected'] = result[0]['total']

        result = self.db.execute_query("SELECT COUNT(*) as count FROM department")
        if result:
            stats['total_departments'] = result[0]['count']

        # Calculate pending from view
        result = self.db.execute_query("SELECT COALESCE(SUM(pending_dues), 0) as total FROM v_student_dues")
        if result:
            stats['total_pending'] = result[0]['total']

        return stats

    # ============================================================
    # STUDENTS SECTION
    # ============================================================
    def show_students(self):
        """Display student management section"""
        self.clear_main_content()

        # Title
        tk.Label(self.main_frame,
                 text="Student Management",
                 font=("Segoe UI", 28, "bold"),
                 fg=self.PRIMARY_COLOR,
                 bg=self.BG_COLOR).pack(anchor=tk.W, pady=(0, 20))

        # Button frame
        btn_frame = tk.Frame(self.main_frame, bg=self.BG_COLOR)
        btn_frame.pack(fill=tk.X, pady=10)

        ttk.Button(btn_frame, text="➕ Add Student", 
                   command=self.open_add_student_window,
                   style="Primary.TButton").pack(side=tk.LEFT, padx=5)

        ttk.Button(btn_frame, text="🔄 Refresh", 
                   command=self.show_students,
                   style="Primary.TButton").pack(side=tk.LEFT, padx=5)

        columns = ("ID", "Roll No", "Name", "Department", "Semester", "Phone", "Status", "Dues")
        col_widths = {"ID": 50, "Roll No": 100, "Name": 180, "Department": 150, 
                      "Semester": 80, "Phone": 120, "Status": 80, "Dues": 120}
        self.students_tree = self.create_tree_with_scrollbars(self.main_frame, columns, col_widths, height=15)

        # Fetch students with dues
        students = self.db.execute_query("""
            SELECT s.student_id, s.roll_no, s.name, d.dept_name, 
                   s.semester, s.phone, s.status,
                   COALESCE(v.pending_dues, 0) as pending_dues
            FROM student s
            JOIN department d ON s.dept_id = d.dept_id
            LEFT JOIN v_student_dues v ON s.student_id = v.student_id
            ORDER BY s.student_id DESC
        """)

        if students:
            for student in students:
                self.students_tree.insert("", tk.END, values=(
                    student['student_id'],
                    student['roll_no'],
                    student['name'],
                    student['dept_name'],
                    student['semester'],
                    student['phone'] or "N/A",
                    student['status'],
                    f"Rs. {student['pending_dues']:,.2f}"
                ))

        # Double-click to view details
        self.students_tree.bind("<Double-1>", self.on_student_double_click)

    def open_add_student_window(self):
        """Open window to add a new student"""
        window = tk.Toplevel(self.root)
        window.title("Add New Student")
        window.geometry("500x600")
        window.configure(bg=self.BG_COLOR)
        window.transient(self.root)
        window.grab_set()

        # Title (outside scroll area)
        tk.Label(window, text="Add New Student", font=("Segoe UI", 18, "bold"),
                 fg=self.PRIMARY_COLOR, bg=self.BG_COLOR).pack(pady=10)

        # Create scrollable frame - fills remaining space
        scroll_frame = ScrollableFrame(window, bg_color=self.BG_COLOR)
        scroll_frame.pack(fill=tk.BOTH, expand=True, padx=20, pady=5)

        form = scroll_frame.scrollable_frame

        # Fields
        fields = [
            ("Roll Number:", "roll_no", "entry"),
            ("Full Name:", "name", "entry"),
            ("Email:", "email", "entry"),
            ("Phone:", "phone", "entry"),
            ("Department:", "dept_id", "combo"),
            ("Semester:", "semester", "spinbox"),
            ("Address:", "address", "text"),
            ("Admission Date:", "admission_date", "date"),
        ]

        entries = {}

        for label_text, field_name, field_type in fields:
            tk.Label(form, text=label_text, font=("Segoe UI", 11),
                     fg=self.PRIMARY_COLOR, bg=self.BG_COLOR).pack(anchor=tk.W, pady=(10, 2))

            if field_type == "entry":
                entry = tk.Entry(form, font=("Segoe UI", 11), bd=2, relief=tk.GROOVE)
                entry.pack(fill=tk.X, pady=2)
                entries[field_name] = entry

            elif field_type == "combo":
                # Get departments
                depts = self.db.execute_query("SELECT dept_id, dept_name FROM department")
                dept_names = [f"{d['dept_id']} - {d['dept_name']}" for d in depts] if depts else []
                combo = ttk.Combobox(form, values=dept_names, font=("Segoe UI", 11), state="readonly")
                combo.pack(fill=tk.X, pady=2)
                entries[field_name] = combo

            elif field_type == "spinbox":
                spin = tk.Spinbox(form, from_=1, to=8, font=("Segoe UI", 11))
                spin.pack(fill=tk.X, pady=2)
                entries[field_name] = spin

            elif field_type == "text":
                text = tk.Text(form, font=("Segoe UI", 11), height=3, bd=2, relief=tk.GROOVE)
                text.pack(fill=tk.X, pady=2)
                entries[field_name] = text

            elif field_type == "date":
                entry = tk.Entry(form, font=("Segoe UI", 11), bd=2, relief=tk.GROOVE)
                entry.insert(0, date.today().strftime("%Y-%m-%d"))
                entry.pack(fill=tk.X, pady=2)
                entries[field_name] = entry

        def save_student():
            """Save student to database"""
            roll_no = entries['roll_no'].get().strip()
            name = entries['name'].get().strip()
            email = entries['email'].get().strip()
            phone = entries['phone'].get().strip()
            dept_text = entries['dept_id'].get()
            semester = entries['semester'].get()
            address = entries['address'].get("1.0", tk.END).strip()
            admission_date = entries['admission_date'].get().strip()

            if not roll_no or not name or not dept_text:
                messagebox.showwarning("Validation Error", "Roll Number, Name, and Department are required!")
                return

            dept_id = int(dept_text.split(" - ")[0])

            query = """INSERT INTO student (roll_no, name, email, phone, dept_id, semester, 
                       address, admission_date, status) 
                       VALUES (%s, %s, %s, %s, %s, %s, %s, %s, 'Active')"""

            if self.db.execute_non_query(query, (roll_no, name, email, phone, 
                                                  dept_id, semester, address, admission_date)):
                messagebox.showinfo("Success", f"Student '{name}' added successfully!")
                window.destroy()
                self.show_students()

        ttk.Button(form, text="💾 Save Student", command=save_student,
                   style="Success.TButton").pack(pady=20)

    def on_student_double_click(self, event):
        """Handle double-click on student row"""
        selected = self.students_tree.selection()
        if not selected:
            return

        item = self.students_tree.item(selected[0])
        student_id = item['values'][0]

        # Show student details
        self.show_student_details(student_id)

    def show_student_details(self, student_id):
        """Show detailed student information"""
        window = tk.Toplevel(self.root)
        window.title(f"Student Details - ID: {student_id}")
        window.geometry("700x500")
        window.configure(bg=self.BG_COLOR)

        # Get student details
        student = self.db.execute_query("""
            SELECT s.*, d.dept_name, d.program
            FROM student s
            JOIN department d ON s.dept_id = d.dept_id
            WHERE s.student_id = %s
        """, (student_id,))

        if not student:
            messagebox.showerror("Error", "Student not found!")
            window.destroy()
            return

        student = student[0]

        # Header
        tk.Label(window, text=f"Student Profile: {student['name']}",
                 font=("Segoe UI", 18, "bold"), fg=self.PRIMARY_COLOR,
                 bg=self.BG_COLOR).pack(pady=15)

        # Details frame
        details = tk.Frame(window, bg=self.CARD_BG, bd=2, relief=tk.RIDGE)
        details.pack(padx=30, pady=10, fill=tk.BOTH, expand=True)

        info = [
            ("Roll Number:", student['roll_no']),
            ("Name:", student['name']),
            ("Email:", student['email'] or "N/A"),
            ("Phone:", student['phone'] or "N/A"),
            ("Department:", f"{student['dept_name']} ({student['program']})"),
            ("Semester:", student['semester']),
            ("Status:", student['status']),
            ("Admission Date:", student['admission_date']),
            ("Address:", student['address'] or "N/A"),
        ]

        for i, (label, value) in enumerate(info):
            tk.Label(details, text=label, font=("Segoe UI", 11, "bold"),
                     fg=self.PRIMARY_COLOR, bg=self.CARD_BG).grid(row=i, column=0, 
                                                                   sticky=tk.W, padx=15, pady=5)
            tk.Label(details, text=str(value), font=("Segoe UI", 11),
                     fg="#2c3e50", bg=self.CARD_BG).grid(row=i, column=1, 
                                                          sticky=tk.W, padx=15, pady=5)

        # Payment history button
        ttk.Button(window, text="💰 Record Payment", 
                   command=lambda: [window.destroy(), self.open_payment_window(student_id)],
                   style="Primary.TButton").pack(pady=15)

    # ============================================================
    # PAYMENTS SECTION
    # ============================================================
    def show_payments(self):
        """Display payments section"""
        self.clear_main_content()

        tk.Label(self.main_frame,
                 text="Payment Management",
                 font=("Segoe UI", 28, "bold"),
                 fg=self.PRIMARY_COLOR,
                 bg=self.BG_COLOR).pack(anchor=tk.W, pady=(0, 20))

        # Button frame
        btn_frame = tk.Frame(self.main_frame, bg=self.BG_COLOR)
        btn_frame.pack(fill=tk.X, pady=10)

        ttk.Button(btn_frame, text="➕ Record Payment", 
                   command=lambda: self.open_payment_window(None),
                   style="Primary.TButton").pack(side=tk.LEFT, padx=5)

        ttk.Button(btn_frame, text="🔄 Refresh", 
                   command=self.show_payments,
                   style="Primary.TButton").pack(side=tk.LEFT, padx=5)

        columns = ("ID", "Receipt No", "Student", "Amount", "Date", "Method", "Reference")
        col_widths = {"ID": 50, "Receipt No": 120, "Student": 180, "Amount": 120,
                        "Date": 100, "Method": 100, "Reference": 120}
        self.payments_tree = self.create_tree_with_scrollbars(self.main_frame, columns, col_widths, height=15)

        # Fetch payments
        payments = self.db.execute_query("""
            SELECT p.payment_id, r.receipt_no, s.name, p.amount, 
                   p.payment_date, p.payment_method, p.reference_no
            FROM payment p
            JOIN student s ON p.student_id = s.student_id
            LEFT JOIN receipt r ON p.payment_id = r.payment_id
            ORDER BY p.payment_date DESC
        """)

        if payments:
            for payment in payments:
                self.payments_tree.insert("", tk.END, values=(
                    payment['payment_id'],
                    payment['receipt_no'] or "N/A",
                    payment['name'],
                    f"Rs. {payment['amount']:,.2f}",
                    payment['payment_date'].strftime("%Y-%m-%d") if payment['payment_date'] else "N/A",
                    payment['payment_method'],
                    payment['reference_no'] or "N/A"
                ))

    def open_payment_window(self, student_id=None):
        """Open window to record a payment"""
        window = tk.Toplevel(self.root)
        window.title("Record Payment")
        window.geometry("500x550")
        window.configure(bg=self.BG_COLOR)
        window.transient(self.root)
        window.grab_set()

        # Title (outside scroll area)
        tk.Label(window, text="Record Payment", font=("Segoe UI", 18, "bold"),
                 fg=self.PRIMARY_COLOR, bg=self.BG_COLOR).pack(pady=10)

        # Create scrollable frame
        scroll_frame = ScrollableFrame(window, bg_color=self.BG_COLOR)
        scroll_frame.pack(fill=tk.BOTH, expand=True, padx=20, pady=5)

        form = scroll_frame.scrollable_frame

        # Student selection
        tk.Label(form, text="Select Student:", font=("Segoe UI", 11),
                 fg=self.PRIMARY_COLOR, bg=self.BG_COLOR).pack(anchor=tk.W, pady=(10, 2))

        students = self.db.execute_query("""
            SELECT s.student_id, s.roll_no, s.name, d.dept_name, s.semester
            FROM student s
            JOIN department d ON s.dept_id = d.dept_id
            WHERE s.status = 'Active'
            ORDER BY s.name
        """)

        student_options = []
        student_map = {}
        if students:
            for s in students:
                option = f"{s['student_id']} - {s['roll_no']} - {s['name']} ({s['dept_name']}, Sem {s['semester']})"
                student_options.append(option)
                student_map[option] = s['student_id']

        student_combo = ttk.Combobox(form, values=student_options, font=("Segoe UI", 11), state="readonly")
        student_combo.pack(fill=tk.X, pady=2)

        # Pre-select if student_id provided
        if student_id:
            for option, sid in student_map.items():
                if sid == student_id:
                    student_combo.set(option)
                    break

        # Amount
        tk.Label(form, text="Amount (Rs.):", font=("Segoe UI", 11),
                 fg=self.PRIMARY_COLOR, bg=self.BG_COLOR).pack(anchor=tk.W, pady=(10, 2))
        amount_entry = tk.Entry(form, font=("Segoe UI", 11), bd=2, relief=tk.GROOVE)
        amount_entry.pack(fill=tk.X, pady=2)

        # Payment Method
        tk.Label(form, text="Payment Method:", font=("Segoe UI", 11),
                 fg=self.PRIMARY_COLOR, bg=self.BG_COLOR).pack(anchor=tk.W, pady=(10, 2))
        method_combo = ttk.Combobox(form, values=["Cash", "Bank Transfer", "Online", "Cheque"],
                                    font=("Segoe UI", 11), state="readonly")
        method_combo.set("Cash")
        method_combo.pack(fill=tk.X, pady=2)

        # Reference Number
        tk.Label(form, text="Reference Number:", font=("Segoe UI", 11),
                 fg=self.PRIMARY_COLOR, bg=self.BG_COLOR).pack(anchor=tk.W, pady=(10, 2))
        ref_entry = tk.Entry(form, font=("Segoe UI", 11), bd=2, relief=tk.GROOVE)
        ref_entry.pack(fill=tk.X, pady=2)

        # Notes
        tk.Label(form, text="Notes:", font=("Segoe UI", 11),
                 fg=self.PRIMARY_COLOR, bg=self.BG_COLOR).pack(anchor=tk.W, pady=(10, 2))
        notes_text = tk.Text(form, font=("Segoe UI", 11), height=3, bd=2, relief=tk.GROOVE)
        notes_text.pack(fill=tk.X, pady=2)

        # Payment Date
        tk.Label(form, text="Payment Date:", font=("Segoe UI", 11),
                 fg=self.PRIMARY_COLOR, bg=self.BG_COLOR).pack(anchor=tk.W, pady=(10, 2))
        date_entry = tk.Entry(form, font=("Segoe UI", 11), bd=2, relief=tk.GROOVE)
        date_entry.insert(0, date.today().strftime("%Y-%m-%d"))
        date_entry.pack(fill=tk.X, pady=2)

        def save_payment():
            """Save payment to database"""
            student_text = student_combo.get()
            if not student_text:
                messagebox.showwarning("Validation Error", "Please select a student!")
                return

            student_id_selected = student_map.get(student_text)
            amount = amount_entry.get().strip()
            method = method_combo.get()
            ref_no = ref_entry.get().strip() or None
            notes = notes_text.get("1.0", tk.END).strip() or None
            pay_date = date_entry.get().strip()

            if not amount or not pay_date:
                messagebox.showwarning("Validation Error", "Amount and Date are required!")
                return

            try:
                amount = float(amount)
                if amount <= 0:
                    raise ValueError
            except ValueError:
                messagebox.showwarning("Validation Error", "Amount must be a positive number!")
                return

            query = """INSERT INTO payment (student_id, amount, payment_date, 
                       payment_method, reference_no, notes, recorded_by)
                       VALUES (%s, %s, %s, %s, %s, %s, 'Admin')"""

            if self.db.execute_non_query(query, (student_id_selected, amount, 
                                                    pay_date, method, ref_no, notes)):
                # Get the receipt number
                receipt = self.db.execute_query("""
                    SELECT receipt_no FROM receipt 
                    WHERE payment_id = %s
                """, (self.db.get_last_insert_id(),))

                receipt_no = receipt[0]['receipt_no'] if receipt else "N/A"
                messagebox.showinfo("Success", 
                    f"Payment recorded successfully!\n\nReceipt No: {receipt_no}")
                window.destroy()
                self.show_payments()

        ttk.Button(form, text="💾 Save Payment", command=save_payment,
                   style="Success.TButton").pack(pady=20)

    # ============================================================
    # FEE STRUCTURE SECTION
    # ============================================================
    def show_fee_structure(self):
        """Display fee structure section"""
        self.clear_main_content()

        tk.Label(self.main_frame,
                 text="Fee Structure Management",
                 font=("Segoe UI", 28, "bold"),
                 fg=self.PRIMARY_COLOR,
                 bg=self.BG_COLOR).pack(anchor=tk.W, pady=(0, 20))

        # Button frame
        btn_frame = tk.Frame(self.main_frame, bg=self.BG_COLOR)
        btn_frame.pack(fill=tk.X, pady=10)

        ttk.Button(btn_frame, text="➕ Add Fee Structure", 
                   command=self.open_add_fee_window,
                   style="Primary.TButton").pack(side=tk.LEFT, padx=5)

        ttk.Button(btn_frame, text="🔄 Refresh", 
                   command=self.show_fee_structure,
                   style="Primary.TButton").pack(side=tk.LEFT, padx=5)

        columns = ("ID", "Department", "Semester", "Total Amount", "Due Date", "Academic Year")
        col_widths = {"ID": 50, "Department": 200, "Semester": 80, "Total Amount": 120,
                      "Due Date": 120, "Academic Year": 120}
        self.fee_tree = self.create_tree_with_scrollbars(self.main_frame, columns, col_widths, height=15)

        # Fetch fee structures
        fees = self.db.execute_query("""
            SELECT f.fee_id, d.dept_name, f.semester, f.total_amount, 
                   f.due_date, f.academic_year
            FROM fee_structure f
            JOIN department d ON f.dept_id = d.dept_id
            ORDER BY d.dept_name, f.semester
        """)

        if fees:
            for fee in fees:
                self.fee_tree.insert("", tk.END, values=(
                    fee['fee_id'],
                    fee['dept_name'],
                    fee['semester'],
                    f"Rs. {fee['total_amount']:,.2f}",
                    fee['due_date'].strftime("%Y-%m-%d") if fee['due_date'] else "N/A",
                    fee['academic_year']
                ))

    def open_add_fee_window(self):
        """Open window to add fee structure"""
        window = tk.Toplevel(self.root)
        window.title("Add Fee Structure")
        window.geometry("450x500")
        window.configure(bg=self.BG_COLOR)
        window.transient(self.root)
        window.grab_set()

        # Title (outside scroll area)
        tk.Label(window, text="Add Fee Structure", font=("Segoe UI", 18, "bold"),
                 fg=self.PRIMARY_COLOR, bg=self.BG_COLOR).pack(pady=10)

        # Create scrollable frame
        scroll_frame = ScrollableFrame(window, bg_color=self.BG_COLOR)
        scroll_frame.pack(fill=tk.BOTH, expand=True, padx=20, pady=5)

        form = scroll_frame.scrollable_frame

        # Department
        tk.Label(form, text="Department:", font=("Segoe UI", 11),
                 fg=self.PRIMARY_COLOR, bg=self.BG_COLOR).pack(anchor=tk.W, pady=(10, 2))

        depts = self.db.execute_query("SELECT dept_id, dept_name FROM department")
        dept_options = [f"{d['dept_id']} - {d['dept_name']}" for d in depts] if depts else []
        dept_combo = ttk.Combobox(form, values=dept_options, font=("Segoe UI", 11), state="readonly")
        dept_combo.pack(fill=tk.X, pady=2)

        # Semester
        tk.Label(form, text="Semester:", font=("Segoe UI", 11),
                 fg=self.PRIMARY_COLOR, bg=self.BG_COLOR).pack(anchor=tk.W, pady=(10, 2))
        sem_spin = tk.Spinbox(form, from_=1, to=8, font=("Segoe UI", 11))
        sem_spin.pack(fill=tk.X, pady=2)

        # Total Amount
        tk.Label(form, text="Total Amount (Rs.):", font=("Segoe UI", 11),
                 fg=self.PRIMARY_COLOR, bg=self.BG_COLOR).pack(anchor=tk.W, pady=(10, 2))
        amount_entry = tk.Entry(form, font=("Segoe UI", 11), bd=2, relief=tk.GROOVE)
        amount_entry.pack(fill=tk.X, pady=2)

        # Due Date
        tk.Label(form, text="Due Date:", font=("Segoe UI", 11),
                 fg=self.PRIMARY_COLOR, bg=self.BG_COLOR).pack(anchor=tk.W, pady=(10, 2))
        date_entry = tk.Entry(form, font=("Segoe UI", 11), bd=2, relief=tk.GROOVE)
        date_entry.insert(0, "2025-09-15")
        date_entry.pack(fill=tk.X, pady=2)

        # Academic Year
        tk.Label(form, text="Academic Year:", font=("Segoe UI", 11),
                 fg=self.PRIMARY_COLOR, bg=self.BG_COLOR).pack(anchor=tk.W, pady=(10, 2))
        year_entry = tk.Entry(form, font=("Segoe UI", 11), bd=2, relief=tk.GROOVE)
        year_entry.insert(0, "2025-2026")
        year_entry.pack(fill=tk.X, pady=2)

        # Description
        tk.Label(form, text="Description:", font=("Segoe UI", 11),
                 fg=self.PRIMARY_COLOR, bg=self.BG_COLOR).pack(anchor=tk.W, pady=(10, 2))
        desc_entry = tk.Entry(form, font=("Segoe UI", 11), bd=2, relief=tk.GROOVE)
        desc_entry.pack(fill=tk.X, pady=2)

        def save_fee():
            dept_text = dept_combo.get()
            if not dept_text:
                messagebox.showwarning("Validation Error", "Please select a department!")
                return

            dept_id = int(dept_text.split(" - ")[0])
            semester = int(sem_spin.get())
            amount = amount_entry.get().strip()
            due_date = date_entry.get().strip()
            academic_year = year_entry.get().strip()
            description = desc_entry.get().strip() or None

            if not amount or not due_date or not academic_year:
                messagebox.showwarning("Validation Error", "All fields except Description are required!")
                return

            try:
                amount = float(amount)
                if amount <= 0:
                    raise ValueError
            except ValueError:
                messagebox.showwarning("Validation Error", "Amount must be a positive number!")
                return

            query = """INSERT INTO fee_structure (dept_id, semester, total_amount, 
                       due_date, description, academic_year)
                       VALUES (%s, %s, %s, %s, %s, %s)"""

            if self.db.execute_non_query(query, (dept_id, semester, amount, 
                                                    due_date, description, academic_year)):
                messagebox.showinfo("Success", "Fee structure added successfully!")
                window.destroy()
                self.show_fee_structure()

        ttk.Button(form, text="💾 Save Fee Structure", command=save_fee,
                   style="Success.TButton").pack(pady=20)

    # ============================================================
    # REPORTS SECTION
    # ============================================================
    def show_reports(self):
        """Display reports section"""
        self.clear_main_content()

        tk.Label(self.main_frame,
                 text="Reports & Analytics",
                 font=("Segoe UI", 28, "bold"),
                 fg=self.PRIMARY_COLOR,
                 bg=self.BG_COLOR).pack(anchor=tk.W, pady=(0, 20))

        # Report buttons
        btn_frame = tk.Frame(self.main_frame, bg=self.BG_COLOR)
        btn_frame.pack(fill=tk.X, pady=10)

        ttk.Button(btn_frame, text="📊 Department Summary", 
                   command=self.show_dept_summary,
                   style="Primary.TButton").pack(side=tk.LEFT, padx=5)

        ttk.Button(btn_frame, text="📋 Semester Report", 
                   command=self.show_semester_report,
                   style="Primary.TButton").pack(side=tk.LEFT, padx=5)

        ttk.Button(btn_frame, text="👤 Student Dues Report", 
                   command=self.show_student_dues_report,
                   style="Primary.TButton").pack(side=tk.LEFT, padx=5)

        # Placeholder for report display
        self.report_frame = tk.Frame(self.main_frame, bg=self.BG_COLOR)
        self.report_frame.pack(fill=tk.BOTH, expand=True, pady=10)

        tk.Label(self.report_frame,
                 text="Select a report from above to view",
                 font=("Segoe UI", 14),
                 fg="#7f8c8d",
                 bg=self.BG_COLOR).pack(expand=True)

    def show_dept_summary(self):
        """Show department summary report"""
        for widget in self.report_frame.winfo_children():
            widget.destroy()

        tk.Label(self.report_frame,
                 text="Department Summary Report",
                 font=("Segoe UI", 18, "bold"),
                 fg=self.PRIMARY_COLOR,
                 bg=self.BG_COLOR).pack(anchor=tk.W, pady=(0, 10))

        columns = ("Department", "Program", "Students", "Expected", "Collected", "Pending")
        col_widths = {"Department": 150, "Program": 150, "Students": 100, "Expected": 140, "Collected": 140, "Pending": 140}
        tree = self.create_tree_with_scrollbars(self.report_frame, columns, col_widths, height=10)

        data = self.db.execute_query("SELECT * FROM v_department_summary")

        if data:
            total_expected = 0
            total_collected = 0
            total_pending = 0

            for row in data:
                tree.insert("", tk.END, values=(
                    row['dept_name'],
                    row['program'],
                    row['total_students'],
                    f"Rs. {row['total_fees_expected']:,.2f}",
                    f"Rs. {row['total_collected']:,.2f}",
                    f"Rs. {row['total_pending']:,.2f}"
                ))
                total_expected += row['total_fees_expected'] or 0
                total_collected += row['total_collected'] or 0
                total_pending += row['total_pending'] or 0

            # Summary bar
            summary = tk.Frame(self.report_frame, bg=self.CARD_BG, bd=2, relief=tk.RIDGE)
            summary.pack(fill=tk.X, pady=10)

            tk.Label(summary, text=f"Total Expected: Rs. {total_expected:,.2f}",
                     font=("Segoe UI", 12, "bold"), fg=self.PRIMARY_COLOR,
                     bg=self.CARD_BG).pack(side=tk.LEFT, padx=20, pady=10)
            tk.Label(summary, text=f"Total Collected: Rs. {total_collected:,.2f}",
                     font=("Segoe UI", 12, "bold"), fg=self.SUCCESS_COLOR,
                     bg=self.CARD_BG).pack(side=tk.LEFT, padx=20, pady=10)
            tk.Label(summary, text=f"Total Pending: Rs. {total_pending:,.2f}",
                     font=("Segoe UI", 12, "bold"), fg=self.ACCENT_COLOR,
                     bg=self.CARD_BG).pack(side=tk.LEFT, padx=20, pady=10)

    def show_semester_report(self):
        """Show semester-wise report"""
        for widget in self.report_frame.winfo_children():
            widget.destroy()

        # Input frame
        input_frame = tk.Frame(self.report_frame, bg=self.BG_COLOR)
        input_frame.pack(fill=tk.X, pady=10)

        tk.Label(input_frame, text="Semester:", font=("Segoe UI", 11),
                 fg=self.PRIMARY_COLOR, bg=self.BG_COLOR).pack(side=tk.LEFT, padx=5)
        sem_spin = tk.Spinbox(input_frame, from_=1, to=8, width=5, font=("Segoe UI", 11))
        sem_spin.pack(side=tk.LEFT, padx=5)

        tk.Label(input_frame, text="Academic Year:", font=("Segoe UI", 11),
                 fg=self.PRIMARY_COLOR, bg=self.BG_COLOR).pack(side=tk.LEFT, padx=5)
        year_entry = tk.Entry(input_frame, width=15, font=("Segoe UI", 11))
        year_entry.insert(0, "2024-2025")
        year_entry.pack(side=tk.LEFT, padx=5)

        def generate():
            semester = int(sem_spin.get())
            year = year_entry.get().strip()

            # Clear previous results
            for widget in self.report_frame.winfo_children()[1:]:
                widget.destroy()

            tk.Label(self.report_frame,
                     text=f"Semester {semester} Report - {year}",
                     font=("Segoe UI", 18, "bold"),
                     fg=self.PRIMARY_COLOR,
                     bg=self.BG_COLOR).pack(anchor=tk.W, pady=(10, 10))

            columns = ("Department", "Students", "Total Fees", "Collected", "Pending")
            col_widths = {"Department": 200, "Students": 120, "Total Fees": 150, "Collected": 150, "Pending": 150}
            tree = self.create_tree_with_scrollbars(self.report_frame, columns, col_widths, height=8)

            data = self.db.execute_query("""
                SELECT d.dept_name, COUNT(DISTINCT s.student_id) as students,
                       COALESCE(SUM(fs.total_amount), 0) as total_fees,
                       COALESCE(SUM(p.amount), 0) as collected
                FROM department d
                LEFT JOIN student s ON d.dept_id = s.dept_id AND s.semester = %s AND s.status = 'Active'
                LEFT JOIN fee_structure fs ON d.dept_id = fs.dept_id AND fs.semester = %s 
                                              AND fs.academic_year = %s
                LEFT JOIN payment p ON s.student_id = p.student_id
                GROUP BY d.dept_id, d.dept_name
            """, (semester, semester, year))

            if data:
                total_fees = 0
                total_collected = 0

                for row in data:
                    pending = (row['total_fees'] or 0) - (row['collected'] or 0)
                    tree.insert("", tk.END, values=(
                        row['dept_name'],
                        row['students'],
                        f"Rs. {row['total_fees']:,.2f}",
                        f"Rs. {row['collected']:,.2f}",
                        f"Rs. {pending:,.2f}"
                    ))
                    total_fees += row['total_fees'] or 0
                    total_collected += row['collected'] or 0

                summary = tk.Frame(self.report_frame, bg=self.CARD_BG, bd=2, relief=tk.RIDGE)
                summary.pack(fill=tk.X, pady=10)

                tk.Label(summary, text=f"Total Fees: Rs. {total_fees:,.2f}",
                         font=("Segoe UI", 12, "bold"), fg=self.PRIMARY_COLOR,
                         bg=self.CARD_BG).pack(side=tk.LEFT, padx=20, pady=10)
                tk.Label(summary, text=f"Total Collected: Rs. {total_collected:,.2f}",
                         font=("Segoe UI", 12, "bold"), fg=self.SUCCESS_COLOR,
                         bg=self.CARD_BG).pack(side=tk.LEFT, padx=20, pady=10)
                tk.Label(summary, text=f"Total Pending: Rs. {total_fees - total_collected:,.2f}",
                         font=("Segoe UI", 12, "bold"), fg=self.ACCENT_COLOR,
                         bg=self.CARD_BG).pack(side=tk.LEFT, padx=20, pady=10)

        ttk.Button(input_frame, text="Generate Report", command=generate,
                   style="Primary.TButton").pack(side=tk.LEFT, padx=20)

    def show_student_dues_report(self):
        """Show student dues report"""
        for widget in self.report_frame.winfo_children():
            widget.destroy()

        tk.Label(self.report_frame,
                 text="Student Dues Report",
                 font=("Segoe UI", 18, "bold"),
                 fg=self.PRIMARY_COLOR,
                 bg=self.BG_COLOR).pack(anchor=tk.W, pady=(0, 10))

        columns = ("Roll No", "Name", "Department", "Semester", "Total Fee", "Paid", "Pending", "Status")
        col_widths = {"Roll No": 100, "Name": 160, "Department": 140, "Semester": 80, 
                      "Total Fee": 120, "Paid": 120, "Pending": 120, "Status": 100}
        tree = self.create_tree_with_scrollbars(self.report_frame, columns, col_widths, height=15)

        data = self.db.execute_query("SELECT * FROM v_student_dues ORDER BY pending_dues DESC")

        if data:
            total_pending = 0
            for row in data:
                tree.insert("", tk.END, values=(
                    row['roll_no'],
                    row['student_name'],
                    row['dept_name'],
                    row['semester'],
                    f"Rs. {row['total_fee']:,.2f}" if row['total_fee'] else "N/A",
                    f"Rs. {row['total_paid']:,.2f}",
                    f"Rs. {row['pending_dues']:,.2f}",
                    row['payment_status']
                ))
                total_pending += row['pending_dues'] or 0

            summary = tk.Frame(self.report_frame, bg=self.CARD_BG, bd=2, relief=tk.RIDGE)
            summary.pack(fill=tk.X, pady=10)

            tk.Label(summary, text=f"Total Pending Dues: Rs. {total_pending:,.2f}",
                     font=("Segoe UI", 14, "bold"), fg=self.ACCENT_COLOR,
                     bg=self.CARD_BG).pack(pady=10)

    # ============================================================
    # SEARCH SECTION
    # ============================================================
    def show_search(self):
        """Display search functionality"""
        self.clear_main_content()

        tk.Label(self.main_frame,
                 text="Search & Filter",
                 font=("Segoe UI", 28, "bold"),
                 fg=self.PRIMARY_COLOR,
                 bg=self.BG_COLOR).pack(anchor=tk.W, pady=(0, 20))

        # Search frame
        search_frame = tk.Frame(self.main_frame, bg=self.CARD_BG, bd=2, relief=tk.RIDGE)
        search_frame.pack(fill=tk.X, pady=10, padx=5)

        tk.Label(search_frame, text="Search Students:", font=("Segoe UI", 12, "bold"),
                 fg=self.PRIMARY_COLOR, bg=self.CARD_BG).pack(side=tk.LEFT, padx=15, pady=15)

        search_entry = tk.Entry(search_frame, font=("Segoe UI", 12), width=40, bd=2, relief=tk.GROOVE)
        search_entry.pack(side=tk.LEFT, padx=10, pady=15)
        search_entry.insert(0, "Enter name or roll number...")

        # Filter by department
        tk.Label(search_frame, text="Department:", font=("Segoe UI", 11),
                 fg=self.PRIMARY_COLOR, bg=self.CARD_BG).pack(side=tk.LEFT, padx=5, pady=15)

        depts = self.db.execute_query("SELECT dept_name FROM department")
        dept_options = ["All"] + [d['dept_name'] for d in depts] if depts else ["All"]
        dept_filter = ttk.Combobox(search_frame, values=dept_options, 
                                   font=("Segoe UI", 11), width=20, state="readonly")
        dept_filter.set("All")
        dept_filter.pack(side=tk.LEFT, padx=5, pady=15)

        # Filter by semester
        tk.Label(search_frame, text="Semester:", font=("Segoe UI", 11),
                 fg=self.PRIMARY_COLOR, bg=self.CARD_BG).pack(side=tk.LEFT, padx=5, pady=15)
        sem_filter = ttk.Combobox(search_frame, values=["All", "1", "2", "3", "4", "5", "6", "7", "8"],
                                  font=("Segoe UI", 11), width=10, state="readonly")
        sem_filter.set("All")
        sem_filter.pack(side=tk.LEFT, padx=5, pady=15)

        # Results frame
        results_frame = tk.Frame(self.main_frame, bg=self.BG_COLOR)
        results_frame.pack(fill=tk.BOTH, expand=True, pady=10)

        columns = ("ID", "Roll No", "Name", "Department", "Semester", "Phone", "Status", "Pending")
        col_widths = {"ID": 50, "Roll No": 100, "Name": 160, "Department": 140, 
                      "Semester": 80, "Phone": 120, "Status": 80, "Pending": 120}
        self.search_tree = self.create_tree_with_scrollbars(results_frame, columns, col_widths, height=15)

        def perform_search():
            """Execute search query"""
            # Clear previous results
            for item in self.search_tree.get_children():
                self.search_tree.delete(item)

            search_term = search_entry.get().strip()
            if search_term == "Enter name or roll number...":
                search_term = ""

            dept = dept_filter.get()
            semester = sem_filter.get()

            query = """
                SELECT s.student_id, s.roll_no, s.name, d.dept_name, 
                       s.semester, s.phone, s.status,
                       COALESCE(v.pending_dues, 0) as pending_dues
                FROM student s
                JOIN department d ON s.dept_id = d.dept_id
                LEFT JOIN v_student_dues v ON s.student_id = v.student_id
                WHERE 1=1
            """
            params = []

            if search_term:
                query += " AND (s.name LIKE %s OR s.roll_no LIKE %s)"
                params.extend([f"%{search_term}%", f"%{search_term}%"])

            if dept != "All":
                query += " AND d.dept_name = %s"
                params.append(dept)

            if semester != "All":
                query += " AND s.semester = %s"
                params.append(int(semester))

            query += " ORDER BY s.name"

            results = self.db.execute_query(query, tuple(params) if params else None)

            if results:
                for row in results:
                    self.search_tree.insert("", tk.END, values=(
                        row['student_id'],
                        row['roll_no'],
                        row['name'],
                        row['dept_name'],
                        row['semester'],
                        row['phone'] or "N/A",
                        row['status'],
                        f"Rs. {row['pending_dues']:,.2f}"
                    ))
            else:
                messagebox.showinfo("Search Results", "No students found matching your criteria.")

        ttk.Button(search_frame, text="🔍 Search", command=perform_search,
                   style="Primary.TButton").pack(side=tk.LEFT, padx=15, pady=15)

        # Bind Enter key
        search_entry.bind("<Return>", lambda e: perform_search())

        # Clear placeholder on focus
        def on_focus_in(event):
            if search_entry.get() == "Enter name or roll number...":
                search_entry.delete(0, tk.END)

        def on_focus_out(event):
            if not search_entry.get():
                search_entry.insert(0, "Enter name or roll number...")

        search_entry.bind("<FocusIn>", on_focus_in)
        search_entry.bind("<FocusOut>", on_focus_out)

    def on_closing(self):
        """Handle application close"""
        if messagebox.askyesno("Exit", "Are you sure you want to exit SFMS?"):
            self.db.disconnect()
            self.root.destroy()


# ============================================================
# APPLICATION ENTRY POINT
# ============================================================
def main():
    """Main function to start the application"""
    root = tk.Tk()

    # Set DPI awareness for better scaling on Windows
    try:
        from ctypes import windll
        windll.shcore.SetProcessDpiAwareness(1)
    except:
        pass

    app = SFMSApp(root)
    root.mainloop()


if __name__ == "__main__":
    main()
