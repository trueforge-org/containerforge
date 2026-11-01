// The values come from the environment, so they do not need escaping and stay out of the process list
function upsertUser(database, name, pwd, roles) {
  if (database.getUser(name)) {
    database.updateUser(name, { pwd, roles });
  } else {
    database.createUser({ user: name, pwd, roles });
  }
}

const { MONGODB_ROOT_PASSWORD, MONGODB_USERNAME, MONGODB_PASSWORD, MONGODB_DATABASE } = process.env;

upsertUser(db.getSiblingDB("admin"), "root", MONGODB_ROOT_PASSWORD, [{ role: "root", db: "admin" }]);

if (MONGODB_USERNAME && MONGODB_PASSWORD && MONGODB_DATABASE) {
  upsertUser(db.getSiblingDB(MONGODB_DATABASE), MONGODB_USERNAME, MONGODB_PASSWORD, [
    { role: "readWrite", db: MONGODB_DATABASE },
  ]);
}
