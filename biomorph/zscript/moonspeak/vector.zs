/*	KeksDose / MemeDose (kd):
	
	How to make rotation matrices 101.
*/

struct BIO_Vec {
	
	static vector3 Direction (double ang, double vang) {
		double cosvang = cos(vang);
		return (cosvang * cos(ang), cosvang * sin(ang), sin(vang));
	}
	
	static vector3 Forward (double ang, double vang) {
		double cosvang = cos(vang);
		return (cosvang * cos(ang), cosvang * sin(ang), -sin(vang));
	}
	
	static vector3 Up (double ang, double vang) {
		double sinvang = sin(vang);
		return (sinvang * cos(ang), sinvang * sin(ang), cos(vang));
	}
	
	static vector3 Right (double ang) {
		return (sin(ang), -cos(ang), 0);
	}
	
	// kd:
	// Three pairwise orthogonal unit vectors (an orthonormal basis), so you
	// can say things like, "50 units in front of you, 200 to the right", no
	// matter your angle and pitch.
	
	// Return order: Forward, Left, Up (so ang = 0, vang = 0, rang = 0 will
	// just give you the xyz-axes directions).
	
	static vector3, vector3, vector3 Onb (double ang, double vang) {
		double cosang	= cos(ang);
		double cosvang	= cos(vang);
		double sinang	= sin(ang);
		double sinvang	= sin(vang);
		
		return	( cosvang * cosang, cosvang * sinang, sinvang),
				(-sinang,   cosang, 0),
				(-sinvang * cosang, -sinvang * sinang, cosvang);
	}
	
	// kd:
	// Same, but rolls the up and side vectors, too.
	
	static vector3, vector3, vector3 RolledOnb (
	double ang, double vang, double rang) {
		double cosang	= cos(ang);
		double cosvang	= cos(vang);
		double cosrang	= cos(rang);
		double sinang	= sin(ang);
		double sinvang	= sin(vang);
		double sinrang	= sin(rang);
		
		vector3 up = (-sinvang * cosang, -sinvang * sinang, cosvang);
		vector3 left = (-sinang, cosang, 0);
		
		return	(cosvang * cosang, cosvang * sinang, sinvang),
				cosrang * left	+ sinrang * up,
				cosrang * up	- cosrang * left;
	}
	
	// kd:
	// These do the same things as the ones above, but the vectors are oriented
	// to match how the screen works (origin at the top left and positive
	// towards bottom right). Using this, I don't have to mess with any -signs.
	
	// Return order: Forward, Right, Down
	
	static vector3, vector3, vector3 ViewOnb (double ang, double vang) {
		double cosang	= cos(ang);
		double cosvang	= cos(vang);
		double sinang	= sin(ang);
		double sinvang	= sin(vang);
		
		return	(cosvang * cosang, cosvang * sinang, sinvang),
				(sinang, -cosang, 0),
				(sinvang * cosang, sinvang * sinang, -cosvang);
	}
	
	static vector3, vector3, vector3 RolledViewOnb (
	double ang, double vang, double rang) {
		double cosang	= cos(ang);
		double cosvang	= cos(vang);
		double cosrang	= cos(rang);
		double sinang	= sin(ang);
		double sinvang	= sin(vang);
		double sinrang	= sin(rang);
		
		vector3 down = (sinvang * cosang, sinvang * sinang, -cosvang);
		vector3 right = (sinang, -cosang, 0);
		
		return	(cosvang * cosang, cosvang * sinang, sinvang),
				cosrang * right	- sinrang * down,
				cosrang * down	+ sinrang * right;
	}
	
	// kd:
	// Some improved vector angle functions:
	
	static double Angle2 (vector2 v) {
		return VectorAngle(v.x, v.y);
	}
	
	static double Angle3 (vector3 v) {
		return VectorAngle(v.x, v.y);
	}
	
	static double Pitch (vector3 v) {
		return VectorAngle(v.xy.length(), v.z);
	}
	
	// kd:
	// Restrain within some objects:
	
	static vector2 Restrain2 (vector2 v, vector2 top_left, vector2 bottom_right) {
		return	(
			clamp(v.x, top_left.x, bottom_right.x),
			clamp(v.y, top_left.y, bottom_right.y));
	}
	
	static vector3 Restrain3 (vector3 v, vector3 top_left, vector3 bottom_right) {
		return	(
			clamp(v.x, top_left.x, bottom_right.x),
			clamp(v.y, top_left.y, bottom_right.y),
			clamp(v.z, top_left.z, bottom_right.z));
	}
	
	// kd:
	// Print some stuff:
	
	static void Print3 (String name, vector3 v) {
		Console.printf("\c[ice]%s\c-: %02.2f %02.2f %02.2f", name, v.x, v.y, v.z);
	}
	
	static void Print2 (String name, vector2 v) {
		Console.printf("\c[ice]%s\c-: %02.2f %02.2f", name, v.x, v.y);
	}
	
	// kd:
	// Boring transformations:
	
	static vector3, vector3, vector3 ScaleX (
	double f, vector3 u, vector3 v, vector3 w) {
		return	(f * u.x, u.y, u.z),
				(f * v.x, v.y, v.z),
				(f * w.x, w.y, w.z);
	}
	
	static vector3, vector3, vector3 ScaleY (
	double f, vector3 u, vector3 v, vector3 w) {
		return	(u.x, f * u.y, u.z),
				(v.x, f * v.y, v.z),
				(w.x, f * w.y, w.z);
	}
	
	static vector3, vector3, vector3 ScaleZ (
	double f, vector3 u, vector3 v, vector3 w) {
		return	(u.x, u.y, f * u.z),
				(v.x, v.y, f * v.z),
				(w.x, w.y, f * w.z);
	}
}

struct BIO_Ang {
	// kd: This is for pixel stretch handling.
	static double Stretch (double f, double ang) {
		return VectorAngle(cos(ang), f * sin(ang));
	}
}
