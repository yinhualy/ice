// **********************************************************************
//
// Copyright (c) 2001
// ZeroC, Inc.
// Billerica, MA, USA
//
// All Rights Reserved.
//
// Ice is free software; you can redistribute it and/or modify it under
// the terms of the GNU General Public License version 2 as published by
// the Free Software Foundation.
//
// **********************************************************************

#ifndef FREEZE_DB_ICE
#define FREEZE_DB_ICE

#include <Ice/CommunicatorF.ice>
#include <Freeze/DBException.ice>
#include <Freeze/DBF.ice>
#include <Freeze/EvictorF.ice>

/**
 *
 * The &Ice; module for object persistence.
 *
 **/
module Freeze
{

/**
 *
 * A database environment. Multiple databases can be created from a
 * single database environment. The database environment also offers
 * operations to create transactions.
 *
 * @see DBTransaction
 * @see DB
 *
 **/
local interface DBEnvironment
{
    /**
     *
     * Get the name of the database environment.
     *
     * @return The name of this database environment.
     *
     **/
    string getName();
     
    /**
     *
     * Get the Communicator for this database environment.
     *
     * @return The Communicator for this database environment.
     *
     **/
    Ice::Communicator getCommunicator();
     
    /**
     *
     * Open and return a database object. If the database does not
     * exist and the [create] flag is false a DBNotFoundException is
     * raised. If the database has been opened before, the previously
     * returned database object is returned again.
     *
     * @param name The database name.
     *
     * @param create Flag that determines whether the database is
     * created, if necessary.
     *
     * @return The database object.
     *
     * @throws DBException Raised if a database failure occurred.
     *
     * @throws DBNotFoundException Raised if a database does not exist
     * and the [create] flag is false.
     *
     * @see DB
     * @see DB::close
     *
     **/
    DB openDB(string name, bool create) throws DBException;

    /**
     *
     * Start a new transaction in this database environment, and
     * return the transaction object for such new transaction.
     *
     * @return The transaction object.
     *
     * @throws DBException Raised if a database failure occurred.
     *
     * @see DBTransaction
     *
     **/
    DBTransaction startTransaction() throws DBException;

    /**
     *
     * Close the database environment and destroy this database
     * environment object. This operation also calls [close] on all
     * databases that have been opened with this database environment
     * object. Subsequent calls to [close] have no effect.
     *
     * @throws DBException Raised if a database failure occurred.
     *
     * @see DB::close
     *
     **/
    void close() throws DBException;
};

/**
 *
 * A transaction object.
 *
 * @see DBEnvironment
 *
 **/
local interface DBTransaction
{
    /**
     *
     * Commit a transaction.
     *
     * @throws DBException Raised if a database failure occurred.
     *
     **/
    void commit() throws DBException;

    /**
     *
     * Abort a transaction.
     *
     * @throws DBException Raised if a database failure occurred.
     *
     **/
    void abort() throws DBException;
};

/**
 *
 * The Evictor persistence mode.
 *
 * @see Evictor
 *
 **/
enum EvictorPersistenceMode
{
    /**
     *
     * This mode instructs the Evictor to save a Servant to persistent
     * store when it is evicted, or when the Evictor is deactivated.
     *
     * @see Ice::ServantLocator::deactivate
     *
     **/
    SaveUponEviction,

    /**
     *
     * This mode instructs the Evictor to save a Servant after each
     * mutating operation call. A mutating operation call is a call to
     * any operation that has not been declared as nonmutating.
     *
     **/
    SaveAfterMutatingOperation
};

/**
 *
 * A database key, represented as a sequence of bytes.
 *
 **/
sequence<byte> Key;

/**
 *
 * A database value, represented as a sequence of bytes
 *
 **/
sequence<byte> Value;

/**
 *
 * A database cursor provides a way to iterate through all key/value
 * pairs in the database.
 *
 * @see DB
 * @see DB::getCursor
 * @see DB::getCursorForKey
 *
 **/
local interface DBCursor
{
    /**
     *
     * Get the Communicator for this cursor.
     *
     * @return The Communicator for this database.
     *
     **/
    Ice::Communicator getCommunicator();

    /**
     *
     * Return the element to which the cursor currently refers.
     *
     * @param k The key of the next element.
     * @param v The value of the next element
     *
     * @throws DBNotFoundException If there are no further elements in
     * the database.
     *
     * @throws DBDeadlockException Raised if a deadlock occurred.
     *
     * @throws DBException Raised if any other database failure
     * occurred.
     *
     **/
    void curr(out Key k, out Value v) throws DBException;

    /**
     *
     * Overwrite the data to which the cursor currently refers.
     *
     * @param v The value to write into the database
     *
     * @throws DBDeadlockException Raised if a deadlock occurred.
     *
     * @throws DBException Raised if any other database failure
     * occurred.
     *
     **/
    void set(Value v) throws DBException;

    /**
     *
     * Move the cursor to the next element in the database.
     *
     * @return false if there is no next element in the database, true
     * otherwise.
     *
     * @throws DBDeadlockException Raised if a deadlock occurred.
     *
     * @throws DBException Raised if any other database failure
     * occurred.
     *
     **/
    bool next() throws DBException;

    /**
     *
     * Move the cursor to the previous element in the database.
     *
     * @return false if there is no previous element in the database,
     * true otherwise.
     *
     * @throws DBDeadlockException Raised if a deadlock occurred.
     *
     * @throws DBException Raised if any other database failure
     * occurred.
     *
     **/
    bool prev() throws DBException;

    /**
     *
     * Remove the key and the corresponding value from the database at
     * the current cursor position.
     *
     * @throws DBNotFoundException Raised if the current element does
     * not exist.
     *
     * @throws DBDeadlockException Raised if a deadlock occurred.
     *
     * @throws DBException Raised if any other database failure
     * occurred.
     *
     **/
    void del() throws DBException;

    /**
     *
     * Clone the cursor.
     *
     * @return The cloned cursor.
     *
     * @throws DBException Raised if a database failure occurred.
     *
     **/
    DBCursor clone() throws DBException;

    /**
     *
     * Close the cursor. Subsequent calls to [close] have no effect.
     *
     * @throws DBException Raised if a database failure occurred.
     *
     **/
    void close() throws DBException;
};

/**
 *
 * A database that can store basic key/value pairs. In addition a
 * database can be used in conjunction with an Evictor (which stores
 * identity/Servant pairs) to provide automatic persistence of servant
 * state. In case the database is used in conjunction with an evictor
 * it is the application's responsbility to make sure that there is no
 * overlap between keys and identities. Identities are simply strings,
 * while values are sequence of bytes. This means that no byte
 * representation of identity strings may be equal to any of the
 * keys. Due to the difficulty to avoid this in practice, the use of
 * one single database to store both key/value and identity/Servant
 * pairs is discouraged.
 *
 * @see DBEnvironment
 * @see DBCursor
 * @see Evictor
 *
 **/
local interface DB
{
    /**
     *
     * Get the Communicator for this database.
     *
     * @return The Communicator for this database.
     *
     **/
    Ice::Communicator getCommunicator();

    /**
     *
     * Get the name of the database.
     *
     * @return The name of this database.
     *
     **/
    string getName();

    /**
     *
     * Get number of key/value pairs in the database.
     *
     * @return The number of pairs.
     *
     * @throws DBException Raised if the database has been closed.
     *
     **/
    long getNumberOfRecords() throws DBException;

    /**
     *
     * Create a cursor for this database.
     *
     * <note><para>Care must be taken to not to close this database,
     * or the database environment this database belongs to, before
     * the Cursor has been properly closed.</para></note>
     *
     * @return A database cursor.
     *
     * @throws DBNotFoundException Raised if the database is empty.
     *
     * @throws DBException Raised if the database has been closed.
     *
     * @see DBCursor
     * @see getCursorAtKey
     *
     **/
    DBCursor getCursor() throws DBException;

    /**
     *
     * Create a cursor for this database. Calling [curr] on the cursor
     * will return the key/value pair for the given key.
     *
     * <note><para>Care must be taken to not to close this database,
     * or the database environment this database belongs to, before
     * the Cursor has been properly closed.</para></note>
     *
     * @return A database cursor.
     *
     * @throws DBNotFoundException If the key was not found in the
     * database.
     *
     * @throws DBDeadlockException Raised if a deadlock occurred.
     *
     * @throws DBException Raised if any other database failure
     * occurred.
     *
     * @see DBCursor
     * @see getCursor
     *
     **/
    DBCursor getCursorAtKey(Key k) throws DBException;

    /**
     *
     * Save a value in the database under a given key.
     *
     * @param k The key under which the value will be stored in
     * the database.
     *
     * @param v The value to store.
     *
     * @throws DBDeadlockException Raised if a deadlock occurred.
     *
     * @throws DBException Raised if any other database failure
     * occurred.
     *
     * @see get
     * @see del
     *
     **/
    void put(Key k, Value v) throws DBException;

    /**
     *
     * Determine if a key is contained in the database.
     *
     * @param k The key to check.
     *
     * @return True if the key is contained in the database, false otherwise.
     *
     * @throws DBNotFoundException Raised if the key was not found in
     * the database.
     *
     * @throws DBDeadlockException Raised if a deadlock occurred.
     *
     * @throws DBException Raised if any other database failure
     * occurred.
     *
     * @see put
     * @see del
     *
     **/
    bool contains(Key k) throws DBException;

    /**
     *
     * Get a value from a database by it's key.
     *
     * @param k The key under which the value is stored in the database
     *
     * @return The value from the database.
     *
     * @throws DBNotFoundException Raised if the key was not found in
     * the database.
     *
     * @throws DBDeadlockException Raised if a deadlock occurred.
     *
     * @throws DBException Raised if any other database failure
     * occurred.
     *
     * @see put
     * @see del
     *
     **/
    Value get(Key k) throws DBException;

    /**
     *
     * Remove a key and the corresponding value from the database. If
     * the key does not exist, this operation will do nothing.
     *
     * @param k The key to remove together with the corresponding
     * value.
     *
     * @throws DBNotFoundException Raised if the key was not found in
     * the database.
     *
     * @throws DBDeadlockException Raised if a deadlock occurred.
     *
     * @throws DBException Raised if any other database failure
     * occurred.
     *
     * @see put
     * @see get
     *
     **/
    void del(Key k) throws DBException;

    /**
     *
     * Clear the database of all records.
     *
     * @throws DBException Raised if a database failure occurred.
     * 
     **/
    void clear() throws DBException;

    /**
     *
     * Close the database and destroy this database object. Subsequent
     * calls to [close] or [remove] have no effect.
     *
     * @throws DBException Raised if a database failure occurred.
     *
     * @see DBEnvironment::openDB
     * @see DBEnvironment::close
     * @see remove
     *
     **/
    void close() throws DBException;

    /**
     *
     * Remove the database and destroy this database
     * object. Subsequent calls to [remove] or [close] have no effect.
     *
     * @throws DBException Raised if a database failure occurred.
     *
     * @see DBEnvironment::openDB
     * @see DBEnvironment::close
     * @see close
     *
     **/
    void remove() throws DBException;

    /**
     *
     * Create a new Evictor that uses this database to store
     * identity/Servant pairs.
     *
     * <note><para>Care must be taken to not to close this database,
     * or the database environment this database belongs to, before
     * the Evictor has been properly deactivated. The Evictor is
     * deactivated by calling [Ice::ObjectAdapter::deactivate] on the
     * object adapter this Evictor is installed with, or by shutting
     * down all Object Adapters with [Ice::Communicator::shutdown]
     * followed by [Ice::Communicator::waitForShutdown].</para></note>
     *
     * @param mode The persistence mode for the new Evictor.
     *
     * @return The new Evictor.
     *
     * @throws DBException Raised if the database has been closed.
     *
     * @see Evictor
     * @see EvictorPersistenceMode
     *
     **/
    Evictor createEvictor(EvictorPersistenceMode mode) throws DBException;
};

};

#endif
