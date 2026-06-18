const API_KEY = "AIzaSyDl-z6ss9OZ_EWeVGpBcIzDSz8-WpECOmk";
const PROJECT_ID = "medicare-2fb52";
const EMAIL = "pavaneshvuchuru@gmail.com";
const PASSWORD = "V.pavanesh$13";

async function run() {
  console.log("Signing in...");
  const authRes = await fetch(`https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${API_KEY}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email: EMAIL, password: PASSWORD, returnSecureToken: true })
  });
  const authData = await authRes.json();
  if (!authData.idToken) {
    console.error("Login failed", authData);
    return;
  }
  const token = authData.idToken;
  console.log("Logged in!");

  // Query users where role == 'hospital_admin'
  console.log("Querying users...");
  const query = {
    structuredQuery: {
      from: [{ collectionId: "users" }],
      where: {
        fieldFilter: {
          field: { fieldPath: "role" },
          op: "EQUAL",
          value: { stringValue: "hospital_admin" }
        }
      }
    }
  };

  const queryRes = await fetch(`https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents:runQuery`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token}` },
    body: JSON.stringify(query)
  });
  
  const queryData = await queryRes.json();
  
  for (const doc of queryData) {
    if (doc.document) {
      const name = doc.document.name; // This is the full path
      console.log("Deleting user:", name);
      await fetch(`https://firestore.googleapis.com/v1/${name}`, {
        method: 'DELETE',
        headers: { 'Authorization': `Bearer ${token}` }
      });
    }
  }

  // Also query adminRequests
  console.log("Querying adminRequests...");
  const query2 = {
    structuredQuery: {
      from: [{ collectionId: "adminRequests" }]
    }
  };
  const queryRes2 = await fetch(`https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents:runQuery`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token}` },
    body: JSON.stringify(query2)
  });
  const queryData2 = await queryRes2.json();
  
  for (const doc of queryData2) {
    if (doc.document) {
      const name = doc.document.name;
      console.log("Deleting adminRequest:", name);
      await fetch(`https://firestore.googleapis.com/v1/${name}`, {
        method: 'DELETE',
        headers: { 'Authorization': `Bearer ${token}` }
      });
    }
  }
  console.log("Done!");
}
run();
