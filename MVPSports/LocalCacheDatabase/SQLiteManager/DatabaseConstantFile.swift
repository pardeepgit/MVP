//
//  DatabaseConstantFile.swift
//  MVPSports
//
//  Created by Chetu India on 26/12/16.
//

import Foundation

let databaseFileName = "MVPSports.sqlite"

let createSiteClassByDateQuery = "CREATE  TABLE SiteClassByDate (ID INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL , classid TEXT, siteid TEXT, className TEXT, classDescription TEXT, classStartTime TEXT, classEndTime TEXT, classLocation TEXT, classInstructor TEXT, classInstructorId TEXT, classInstructorImage TEXT, checkedId TEXT, userFavourite BOOL DEFAULT false, userCheckIn BOOL DEFAULT false, classInstructorAvailable BOOL DEFAULT false);"

let createSiteClassByInstructorQuery = "CREATE  TABLE SiteClassByInstructor (ID INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL , classid TEXT, siteid TEXT, className TEXT, classDescription TEXT, classStartTime TEXT, classEndTime TEXT, classLocation TEXT, classInstructor TEXT, classInstructorId TEXT, classInstructorImage TEXT, checkedId TEXT, userFavourite BOOL DEFAULT false, userCheckIn BOOL DEFAULT false, classInstructorAvailable BOOL DEFAULT false);"

let createSiteClassByClassesQuery = "CREATE  TABLE SiteClassByClasses (ID INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL , classid TEXT, siteid TEXT, className TEXT, classDescription TEXT, classStartTime TEXT, classEndTime TEXT, classLocation TEXT, classInstructor TEXT, classInstructorId TEXT, classInstructorImage TEXT, checkedId TEXT, userFavourite BOOL DEFAULT false, userCheckIn BOOL DEFAULT false, classInstructorAvailable BOOL DEFAULT false);"

let createSiteClassByUserFavouriteQuery = "CREATE  TABLE SiteClassByUserFavourite (ID INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL , classid TEXT, siteid TEXT, className TEXT, classDescription TEXT, classStartTime TEXT, classEndTime TEXT, classLocation TEXT, classInstructor TEXT, classInstructorId TEXT, classInstructorImage TEXT, checkedId TEXT, userFavourite BOOL DEFAULT false, userCheckIn BOOL DEFAULT false, classInstructorAvailable BOOL DEFAULT false);"

let deleteFromSiteClassByDateQuery = "DELETE FROM SiteClassByDate;"
let deleteFromSiteClassByInstructorQuery = "DELETE FROM SiteClassByInstructor;"
let deleteFromSiteClassByClassesQuery = "DELETE FROM SiteClassByClasses;"
let deleteFromSiteClassByUserFavouriteQuery = "DELETE FROM SiteClassByUserFavourite;"

let loadFromSiteClassByDateQuery = "SELECT * FROM SiteClassByDate"
let loadFromSiteClassByInstructorQuery = "SELECT * FROM SiteClassByInstructor"
let loadFromSiteClassByClassesQuery = "SELECT * FROM SiteClassByClasses"
let loadFromSiteClassByUserFavouriteQuery = "SELECT * FROM SiteClassByUserFavourite"

let loadClassIdFromSiteClassByDateQuery = "Select classid FROM SiteClassByDate where classid = ?"
