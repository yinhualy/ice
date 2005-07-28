// **********************************************************************
//
// Copyright (c) 2003-2005 ZeroC, Inc. All rights reserved.
//
// This copy of Ice is licensed to you under the terms described in the
// ICE_LICENSE file included in this distribution.
//
// **********************************************************************

#ifndef ICE_GRID_SERVERCACHE_H
#define ICE_GRID_SERVERCACHE_H

#include <IceUtil/Mutex.h>
#include <IceUtil/Shared.h>
#include <IceGrid/Descriptor.h>
#include <IceGrid/Internal.h>
#include <IceGrid/Cache.h>
#include <IceGrid/NodeCache.h>

namespace IceGrid
{

class Database;

class ServerCache;
class AdapterCache;
class ObjectCache;

class ServerEntry : public IceUtil::Shared, public IceUtil::Monitor<IceUtil::Mutex>
{
public:
    
    ServerEntry(Cache<std::string, ServerEntry>&, const std::string&);
    
    void sync();
    bool needsSync() const;
    void update(const ServerInfo&);
    void destroy();

    ServerInfo getServerInfo() const;
    std::string getId() const;

    ServerPrx getProxy(int&, int&);
    AdapterPrx getAdapter(const std::string&);

    bool canRemove();
    bool isDestroyed();
    
private:
    
    ServerPrx sync(StringAdapterPrxDict&, int&, int&);

    ServerCache& _cache;
    const std::string _id;
    std::auto_ptr<ServerInfo> _loaded;
    std::auto_ptr<ServerInfo> _load;
    std::auto_ptr<ServerInfo> _destroy;

    ServerPrx _proxy;
    std::map<std::string, AdapterPrx> _adapters;
    int _activationTimeout;
    int _deactivationTimeout;

    bool _synchronizing;
    bool _failed;
};
typedef IceUtil::Handle<ServerEntry> ServerEntryPtr;
typedef std::vector<ServerEntryPtr> ServerEntrySeq;

class ServerCache : public CacheByString<ServerEntry>
{
public:

    ServerCache(Database&, NodeCache&, AdapterCache&, ObjectCache&);

    ServerEntryPtr add(const ServerInfo&);
    ServerEntryPtr get(const std::string&);
    ServerEntryPtr remove(const std::string&, bool = true);

    void clear(const std::string&);
    
    Database& getDatabase() const;

private:
    
    void addCommunicator(const CommunicatorDescriptorPtr&, const ServerEntryPtr&);
    void removeCommunicator(const CommunicatorDescriptorPtr&, const ServerEntryPtr&);

    friend struct AddCommunicator;
    friend struct RemoveCommunicator;

    Database& _database;
    NodeCache& _nodeCache;
    AdapterCache& _adapterCache;
    ObjectCache& _objectCache;
};

};

#endif
