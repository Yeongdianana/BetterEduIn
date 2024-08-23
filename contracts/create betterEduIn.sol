// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AcademicRecords {
    struct Certificate {
        string studentName;
        string courseName;
        string grade;
        string dateIssued;
        address issuedBy;
    }

    mapping(bytes32 => Certificate) private certificates;
    mapping(address => bool) public authorizedSchools;

    address public admin;

    event CertificateIssued(bytes32 indexed certHash, address indexed issuedBy, string studentName, string courseName);

    constructor() {
        admin = msg.sender;
    }

    // Modifier to allow only the admin to authorize schools
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    // Modifier to allow only authorized schools to issue certificates
    modifier onlyAuthorizedSchool() {
        require(authorizedSchools[msg.sender], "Only authorized schools can issue certificates");
        _;
    }
    // Function to authorize a school
    function authorizeSchool(address school) external onlyAdmin {
        authorizedSchools[school] = true;
    }

    // Function to revoke authorization from a school
    function revokeSchoolAuthorization(address school) external onlyAdmin {
        authorizedSchools[school] = false;
    }

    // Function for schools to issue a certificate
    function issueCertificate(
        string memory _studentName,
        string memory _courseName,
        string memory _grade,
        string memory _dateIssued
    ) external onlyAuthorizedSchool returns (bytes32) {
        bytes32 certHash = keccak256(abi.encodePacked(_studentName, _courseName, _dateIssued, msg.sender));
        certificates[certHash] = Certificate(_studentName, _courseName, _grade, _dateIssued, msg.sender);

        emit CertificateIssued(certHash, msg.sender, _studentName, _courseName);
        return certHash;
    }

    // Function to verify a certificate by hash
    function verifyCertificate(bytes32 certHash) external view returns (bool, Certificate memory) {
        Certificate memory cert = certificates[certHash];
        if (cert.issuedBy != address(0)) {
            return (true, cert);
        }
        return (false, cert);
    }
}
