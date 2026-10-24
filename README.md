# DuplicateDetector — Duplicate File Detection System

A Java-based web application that identifies duplicate files by comparing their SHA-256 content hashes. The system helps users analyze uploaded files, view scan results, and estimate potential storage savings through a web interface.

## Overview

DuplicateDetector is a full-stack Java web application built using JSP, Servlets, JDBC, and MySQL. It processes uploaded files, calculates SHA-256 hashes, detects repeated file contents, and stores scan history and file metadata in a database.

The application uses a MySQL database hosted on Aiven for cloud database connectivity.

## Features

- **User Authentication:** User registration and login.
- **File Upload:** Upload multiple files for scanning.
- **SHA-256 Hashing:** Generate content hashes to identify files with identical contents.
- **Duplicate Detection:** Identify repeated file contents within a scan.
- **Scan Summary:** Display the total files scanned and duplicates found.
- **Storage Analysis:** Estimate potential storage savings from duplicate files.
- **Scan History:** Store scan information and scanned-file metadata.
- **Admin Features:** Administrative pages for user management and account-status requests.
- **Database Transactions:** Save scan history and file metadata together.
- **Responsive Interface:** Web pages designed for desktop and mobile screens.

## Technology Stack

| Technology | Purpose |
|---|---|
| Java | Application logic |
| JSP | Web pages and result presentation |
| Jakarta Servlets | Request handling and application processing |
| JDBC | Java-to-database connectivity |
| MySQL | Persistent data storage |
| Aiven | Cloud-hosted MySQL database |
| Apache Tomcat 11 | Servlet container and application server |
| SHA-256 | File-content hashing |
| HTML and CSS | Web interface |

## How It Works

1. The user logs in to the application.
2. The user selects one or more files to scan.
3. The server processes the uploaded files.
4. A SHA-256 hash is calculated for each file.
5. Files with matching hashes are identified as duplicates within that scan.
6. The application calculates the duplicate count and estimated space savings.
7. Scan history and file metadata are saved in the database.
8. The user views the scan results through the web interface.

**Note:** Duplicate detection is based on file contents, not only file names. The current scan logic compares files selected in the same scan.

## Prerequisites

Install the following software before running the application:

- Java Development Kit (JDK) 21
- Eclipse IDE for Enterprise Java and Web Developers
- Apache Tomcat 11
- MySQL-compatible database
- MySQL Connector/J JDBC driver
- Git (optional, for cloning the repository)

You will also need access to a MySQL database. You can use a local MySQL installation or a cloud-hosted MySQL service such as Aiven.

## Getting Started

### 1. Clone the repository

Open a terminal and run:

```bash
git clone https://github.com/ravanan-true/DuplicateDetector.git
cd DuplicateDetector
```

Alternatively, download the repository as a ZIP file from GitHub.

### 2. Import the project into Eclipse

1. Open Eclipse.
2. Select **File → Import**.
3. Choose **General → Existing Projects into Workspace**, if the project structure is recognized by Eclipse.
4. Browse to the downloaded or cloned project folder.
5. Select the project and finish the import.

If Eclipse does not recognize the project automatically, configure it as a Java web project and set up the required Java and Tomcat runtimes.

### 3. Create a database

Create a MySQL database for the application.

For example, the database name may be:

```sql
CREATE DATABASE duplicate_detector;
```

The SQL above creates an empty database only. The application also requires the tables and columns expected by its Java code, including `users`, `scan_history`, and `scanned_files`. Use a compatible schema before running the application.

Do not commit database dumps containing real user data, passwords, or other sensitive information.

### 4. Configure database connectivity

Configure the database connection in:

`src/main/java/com/duplicatedetector/util/DBConnection.java`

Use environment variables for sensitive connection details rather than hardcoding passwords.

The current application configuration expects a password environment variable named:

`DB_PASSWORD`

Set `DB_PASSWORD` to your database password in the environment used to run Tomcat. In Eclipse, configure it in the Tomcat server's launch environment.

For a cloud database, use the host, port, database name, and username provided by your database provider. Enable the provider's required TLS/SSL settings.

**Security:** Never publish database passwords, private keys, access tokens, or real production credentials in source code or GitHub.

### 5. Configure Apache Tomcat 11

1. Add Apache Tomcat 11 to Eclipse under **Window → Preferences → Server → Runtime Environments**.
2. Assign the Tomcat runtime to the web project.
3. Confirm that the project uses a compatible Java version.
4. Ensure the MySQL Connector/J driver is available to the application.
5. Start the Tomcat server.

### 6. Run the application

1. In Eclipse, right-click the project.
2. Select **Run As → Run on Server**.
3. Select your configured Tomcat 11 server.
4. Open the local application URL provided by Eclipse.

The URL commonly follows this pattern:

`http://localhost:8080/DuplicateDetector/`

The exact URL depends on the configured context path. Open the application's login or home page, register or sign in, and test a file scan.

## Security and Upload Configuration

- Keep database credentials outside source control.
- Use a dedicated temporary upload directory that exists and is writable by Tomcat.
- Review upload size limits and available disk space before scanning large files.
- Do not upload sensitive personal or confidential files to a public or untrusted deployment.
- Use HTTPS when deploying the application publicly.
- Configure database permissions with the least privilege needed by the application.

## Current Limitations

- Duplicate detection currently compares files within an individual scan; it does not automatically identify duplicates across separate scan sessions.
- Potential storage savings are estimates based on the sizes of duplicate files.
- Deployment configuration, database schema, and runtime settings must be prepared for the target environment.

## Future Improvements

- Compare new scans with previously scanned files.
- Add file-type filtering and improved scan reporting.
- Provide downloadable scan reports.
- Add pagination and search to scan history.
- Improve deployment automation and production monitoring.

## Project Structure

```text
DuplicateDetector/
├── src/
│   └── main/
│       ├── java/
│       │   └── com/
│       │       └── duplicatedetector/
│       │           ├── servlet/
│       │           └── util/
│       └── webapp/
│           ├── WEB-INF/
│           ├── dashboard.jsp
│           ├── index.jsp
│           ├── login.jsp
│           ├── register.jsp
│           └── scan-history.jsp
├── .gitignore
└── README.md
```

## Author

**Ragul B**

GitHub: [@ravanan-true](https://github.com/ravanan-true)

## License

No license has been specified yet. Unless a license is added, others do not automatically receive permission to reuse, modify, or distribute this project.
