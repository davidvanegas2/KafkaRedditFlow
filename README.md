# **Kafka Data Pipeline Project**

This personal project is a practical implementation of a **data pipeline** based on **Apache Kafka**, designed to showcase skills in **data engineering** and **Infrastructure as Code (IaC)**. The core idea is to capture, process, and store data efficiently using Kafka as the central platform for real-time data streaming.

----------

### **Objective**

Build a pipeline that:

1.  **Produces data**: A producer sends data from an external source (currently implemented using the Reddit API) to a Kafka cluster.
2.  **Processes and consumes data**: Consumers extract and process the data as per specific requirements.
3.  **Persists data**: Data is stored in S3 through Amazon Kinesis Firehose for further analysis and modeling.
4.  **Reproducible infrastructure**: Everything is configured using Terraform to ensure automated and standardized deployment.

----------

### **Main components**

-   **Kafka as the core**: A Kafka cluster deployed on AWS using **Managed Streaming for Apache Kafka (MSK)** to ensure scalability and reliability.
-   **Python producer**: Built with the `confluent-kafka` library, this module connects to Kafka and publishes messages with JSON-structured data.
-   **Consumer (in development)**: Planned to consume data from Kafka and transform it before storing it or integrating it with other applications.
-   **Infrastructure as Code (IaC)**: Utilizes **Terraform** to configure and deploy the MSK cluster, private subnets, IAM roles, and other AWS resources.
-   **CI/CD pipeline**: Automates module updates and manages code changes deployment for the producer.

----------

### **Technologies used**

-   **Apache Kafka** for real-time data streaming.
-   **AWS**:
    -   **MSK** for the Kafka cluster.
    -   **Kinesis Firehose** for ingesting and storing data in S3.
    -   **EC2** to run the producer and consumers.
-   **Python** as the primary programming language.
-   **Terraform** for infrastructure management.
-   **GitHub Actions** (planned) to automate CI/CD processes.

----------

### **Dependencies**

To deploy the infrastructure using Terraform, ensure that the following tools are installed and configured on your local machine:

-   **Terraform**: For managing the infrastructure.
-   **jq**: A lightweight and flexible command-line JSON processor, required for processing certain Terraform configurations. Install it using your system's package manager, e.g.:
    -   For Debian/Ubuntu: `sudo apt install jq`
    -   For macOS: `brew install jq`
    -   For Windows: Use a package manager like Chocolatey or manually download the binary from the official [jq website](https://stedolan.github.io/jq/).

----------

### **Why this project is important**

This repository not only demonstrates a functional example of building a modern data pipeline but also highlights:

-   Expertise in **cloud computing** using AWS.
-   Experience in configuring and managing **Kafka**.
-   High-level practices in **Infrastructure as Code**.
-   Use of modern techniques for managing and deploying pipelines.

----------

### **Current status**

 - [x] MSK configuration with Terraform.
 - [x] Working producer with data from Reddit API.
 - [ ] Basic consumer in development.
 - [ ] Kinesis Firehose configuration for persistence in S3.
 - [ ] Comprehensive documentation of all steps and commands in Markdown to facilitate project replication.

----------

### **How to contribute**

Although this is a personal project, any feedback or suggestions are welcome. Feel free to open an **issue** or submit a **pull request** if you find something that can be improved!
