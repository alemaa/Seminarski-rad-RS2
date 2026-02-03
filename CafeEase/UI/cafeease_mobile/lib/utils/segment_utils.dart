String getUserSegment(int points) {
  if (points >= 50) return "VIP";
  if(points >= 20) return "NEW";
  return "ALL";
}
