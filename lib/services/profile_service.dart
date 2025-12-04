
import '../models/motorcycle_model.dart';

// --- MODELO DE PERFIL DE USUARIO ---
class UserProfile {
  final String id;
  final String username;
  final String email;
  final String avatarUrl;
  final List<Motorcycle> motorcycles;

  UserProfile({
    required this.id,
    required this.username,
    required this.email,
    required this.avatarUrl,
    required this.motorcycles,
  });
}

// --- SERVICIO DE PERFIL (SIMULADO) ---
class ProfileService {
  // Simula una base de datos de perfiles de usuario.
  static final UserProfile _sampleProfile = UserProfile(
    id: 'user123',
    username: 'jonfer119',
    email: 'huesomillonario666@gmail.com',
    avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=800&q=80',
    motorcycles: [
      Motorcycle(
        id: 'moto1',
        nickname: 'NS400Z Oscura',
        brand: 'Bajaj',
        model: 'Dominar 400',
        year: 2023,
        mileage: 12500,
        imageUrl: 'https://images.unsplash.com/photo-1568772585407-9361f9bf3a87?q=80&w=2070&auto=format&fit=crop',
        modifications: [
          Modification(title: 'Wrap G59 Custom', description: 'Diseño Fractura Oscura', isVerified: true),
          Modification(title: 'Escape Full System', description: 'Akrapovic Carbon'),
        ],
      ),
      Motorcycle(
        id: 'moto2',
        nickname: 'La Furia Roja',
        brand: 'Ducati',
        model: 'Panigale V2',
        year: 2022,
        mileage: 5800,
        imageUrl: 'https://images.unsplash.com/photo-1617109829224-f4344548074c?q=80&w=1974&auto=format&fit=crop',
        modifications: [
          Modification(title: 'Portamatrículas corto', description: 'Rizoma'),
        ],
      ),
    ],
  );

  // Obtiene el perfil del usuario logueado (simulado)
  Future<UserProfile> getUserProfile() async {
    // Simula una llamada de red
    await Future.delayed(const Duration(milliseconds: 800));
    return _sampleProfile;
  }

  // Añade una nueva moto (simulado)
  Future<void> addMotorcycle(Motorcycle newMoto) async {
    await Future.delayed(const Duration(seconds: 1));
    _sampleProfile.motorcycles.add(newMoto);
  }
}
