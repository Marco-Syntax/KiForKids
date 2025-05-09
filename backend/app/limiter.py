"""
Konfiguriert den Rate Limiter für API-Endpunkte.
Begrenzt die Anzahl der Anfragen pro Zeiteinheit.
"""

from slowapi import Limiter
from slowapi.util import get_remote_address

# Initialisiere den Limiter mit der Funktion zur IP-Adress-Erkennung
limiter = Limiter(key_func=get_remote_address)
