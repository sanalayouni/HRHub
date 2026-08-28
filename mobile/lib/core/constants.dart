// Chrome/Edge (web) and Windows desktop both reach the FastAPI dev server
// on the host machine via localhost. If running on an Android emulator,
// this needs to be 10.0.2.2 instead of 127.0.0.1.
const String apiBaseUrl = "http://10.0.2.2:8000/api/v1";
