enum UserRole {
  patient("Patient", "patient"),
  doctor("Doctor", "doctor"),
  hospitalAdmin("Hospital Admin", "hospital_admin"),
  receptionist("Receptionist", "receptionist"),
  labTechnician("Lab Technician", "lab_technician"),
  mainAdmin("Main Admin", "main_admin");

  final String title;
  final String dbValue;
  const UserRole(this.title, this.dbValue);
}
