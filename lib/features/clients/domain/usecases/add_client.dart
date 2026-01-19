import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/client.dart';
import '../repositories/client_repository.dart';

/// Use case for adding a new client
class AddClient {
  final ClientRepository _repository;

  AddClient(this._repository);

  /// Executes the use case
  Future<Result<Client>> call(AddClientParams params) async {
    // Validate input
    final validationError = _validate(params);
    if (validationError != null) {
      return Error(validationError);
    }

    // Create the client
    return _repository.createClient(
      CreateClientParams(
        email: params.email.trim().toLowerCase(),
        firstName: params.firstName.trim(),
        lastName: params.lastName.trim(),
        phone: params.phone?.trim(),
        profile: params.profile,
      ),
    );
  }

  /// Validates the input parameters
  ValidationFailure? _validate(AddClientParams params) {
    final errors = <String, List<String>>{};

    // Validate email
    if (params.email.trim().isEmpty) {
      errors['email'] = ['Email is required'];
    } else if (!_isValidEmail(params.email)) {
      errors['email'] = ['Invalid email format'];
    }

    // Validate first name
    if (params.firstName.trim().isEmpty) {
      errors['firstName'] = ['First name is required'];
    } else if (params.firstName.trim().length < 2) {
      errors['firstName'] = ['First name must be at least 2 characters'];
    }

    // Validate last name
    if (params.lastName.trim().isEmpty) {
      errors['lastName'] = ['Last name is required'];
    } else if (params.lastName.trim().length < 2) {
      errors['lastName'] = ['Last name must be at least 2 characters'];
    }

    // Validate phone if provided
    if (params.phone != null && params.phone!.isNotEmpty) {
      if (!_isValidPhone(params.phone!)) {
        errors['phone'] = ['Invalid phone number format'];
      }
    }

    if (errors.isNotEmpty) {
      return ValidationFailure(
        message: 'Please fix the validation errors',
        fieldErrors: errors,
      );
    }

    return null;
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email.trim());
  }

  bool _isValidPhone(String phone) {
    // Allow digits, spaces, dashes, parentheses, and plus sign
    final phoneRegex = RegExp(r'^[\d\s\-\(\)\+]+$');
    final digitsOnly = phone.replaceAll(RegExp(r'\D'), '');
    return phoneRegex.hasMatch(phone) && digitsOnly.length >= 7;
  }
}

/// Parameters for AddClient use case
class AddClientParams {
  final String email;
  final String firstName;
  final String lastName;
  final String? phone;
  final ClientProfile? profile;

  const AddClientParams({
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.profile,
  });
}

