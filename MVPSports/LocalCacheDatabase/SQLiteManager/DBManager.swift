//
//  DBManager.swift
//  SQLiteWithFMDB
//
//  Created by Pardeep Kumar on 25/12/2016.
//  Copyright © 2016 Pardeep Kumar. All rights reserved.
//

import UIKit


class DBManager: NSObject {

  
  static let sharedInstance = DBManager()
  var pathToDatabase: String!
  var database: FMDatabase!

  
  
  // MARK:  default constructor init method.
  private override init() {
    super.init()
    let documentsDirectory = (NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString) as String
    pathToDatabase = "\(documentsDirectory)/\(databaseFileName)"
  }
  
  // MARK:  openDatabase method.
  func openDatabase() -> Bool {
    if database == nil {
      let fileManager = NSFileManager.defaultManager()
      if fileManager.fileExistsAtPath(pathToDatabase) {
        database = FMDatabase(path: pathToDatabase)
      }
    }
    
    if database != nil {
      if database.open() {
        return true
      }
    }
    
    return false
  }
  
  // MARK:  closeDatabase method.
  func closeDatabase() -> Bool {
    if database != nil {
      if database.close() {
        return true
      }
    }
    return false
  }
  
  // MARK:  createDatabase method.
  func createDatabase() -> Bool {
    var created = false
    let fileManager = NSFileManager.defaultManager()
    if !fileManager.fileExistsAtPath(pathToDatabase) {
      database = FMDatabase(path: pathToDatabase!)
      if database != nil {
        // Open the database.
        if database.open() {
          let queryString = "\(createSiteClassByDateQuery)\("\n")\(createSiteClassByInstructorQuery)\("\n")\(createSiteClassByClassesQuery)\("\n")\(createSiteClassByUserFavouriteQuery)"
          // print(queryString)
          created = database.executeStatements(queryString)
          if created == true{
            // print("success")
          }
          database.close()
        }
        else {
          print("Could not open the database.")
        }
      }
    }
    return created
  }

  
  
  
  // MARK:  executeInsertQueryBy method.
  func executeInsertQueryBy(query: String) {
    if openDatabase() {
      do {
        try database.executeUpdate(query, values: nil)
        // print("Inserted succesfully.")
      }
      catch {
        print(error)
      }
      
      // database.close()
    }
  }

  // MARK:  executeLoadQueryBy method.
  func executeLoadQueryBy(query: String) -> FMResultSet? {
    var results: FMResultSet?
    if openDatabase() {
      do {
        try results = database.executeQuery(query, values: nil)
      }
      catch {
        print(error)
      }
      
      // database.close()
    }
    
    return results
  }

  // MARK:  executeLoadQueryBy andFor value method.
  func executeLoadQueryBy(query: String, andValue value: AnyObject) -> FMResultSet? {
    var results: FMResultSet?
    if openDatabase() {
      do {
        try results = database.executeQuery(query, values: [value])
      }
      catch {
        print(error)
      }
      
      // database.close()
    }
    
    return results
  }
  
  // MARK:  executeDeleteQueryBy method.
  func executeDeleteQueryBy(query: String) -> Bool {
    var deleted = false

    if openDatabase() {
      deleted = database.executeStatements(query)
      // print("Delete query executed.")
      // database.close()
    }
    
    return deleted
  }
  
  // MARK:  executeUpdateQueryBy method.
  func executeUpdateQueryBy(query: String) -> Bool {
    var update = false
    
    if openDatabase() {
      update = database.executeStatements(query)
      // print("Update query executed.")
      // database.close()
    }
    
    return update
  }

}
