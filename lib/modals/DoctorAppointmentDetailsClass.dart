class DoctorAppointmentDetailsClass {
  String success;
  String register;
  Data data;

  DoctorAppointmentDetailsClass({this.success, this.register, this.data});

  DoctorAppointmentDetailsClass.fromJson(Map<String, dynamic> json) {
    success = json['success'].toString();
    register = json['register'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['register'] = this.register;
    if (this.data != null) {
      data['data'] = this.data.toJson();
    }
    return data;
  }
}

class Data {
  String image;
  String name;
  int status;
  String date;
  String slot;
  String phone;
  String email;
  String description;
  int id;
  String prescription;

  Data(
      {this.image,
        this.name,
        this.status,
        this.date,
        this.slot,
        this.phone,
        this.email,
        this.description,
        this.prescription,
        this.id});

  Data.fromJson(Map<String, dynamic> json) {
    image = json['image'];
    name = json['name'];
    status = json['status'];
    date = json['date'];
    slot = json['slot'];
    phone = json['phone'].toString();
    email = json['email'];
    description = json['description'].toString();
    id = json['id'];
    prescription = json['prescription'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['image'] = this.image;
    data['name'] = this.name;
    data['status'] = this.status;
    data['date'] = this.date;
    data['slot'] = this.slot;
    data['phone'] = this.phone;
    data['email'] = this.email;
    data['description'] = this.description;
    data['id'] = this.id;
    return data;
  }
}
