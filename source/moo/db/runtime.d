/*//////////////////////////////////////////////////////////////////////////////////////////////////
////                                                                                            ////
////    Copyright 2014 Christopher Nicholson-Sauls                                              ////
////                                                                                            ////
////    Licensed under the Apache License, Version 2.0 (the "License"); you may not use this    ////
////    file except in compliance with the License.  You may obtain a copy of the License at    ////
////                                                                                            ////
////        http://www.apache.org/licenses/LICENSE-2.0                                          ////
////                                                                                            ////
////    Unless required by applicable law or agreed to in writing, software distributed         ////
////    under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR             ////
////    CONDITIONS OF ANY KIND, either express or implied.  See the License for the specific    ////
////    language governing permissions and limitations under the License.                       ////
////                                                                                            ////
//////////////////////////////////////////////////////////////////////////////////////////////////*/

/**
 *  Database system runtime and main API.
 */
module moo.db.runtime;

import  moo.config      ,
        moo.exception   ,
        moo.log         ,
        moo.db.types    ;


/**
 *
 */
private bool _active = false;


/**
 *
 */
private size_t _dumpCounter = 0;


/**
 *
 */
private MObject[] _world;


/**
 *
 */
@property @safe MObject[] allObjects() nothrow
{
    MObject[] result;
    result.reserve(_world.length);

    void step(MObject obj) nothrow
    {
        if (obj !is null)
        {
            result ~= obj;
            obj = obj.child;
            while (obj !is null)
            {
                step(obj);
                obj = obj.sibling;
            }
        }
    }

    step(getObject(1));
    return result;
}


/**
 *
 */
@property @safe MInt maxValidObjectID() nothrow
{
    MInt result = -1;
    foreach_reverse (i, x; _world)
    {
        if (x !is null && !x.recycled)
        {
            result = i;
            break;
        }
    }
    return result;
}


/**
 *  Get an object from the database, optionally creating the object (and expanding the database) as
 *  needed.  By default it will return null for an invalid object or id out of range.
 *
 *  Params:
 *      id              = desired object's #id
 *      shouldCreate    = (optional) pass true to create the object as needed
 *
 *  Returns: the object, or null if invalid and shouldCreate is false
 */
@safe MObject getObject(in MInt id, in bool shouldCreate = false) nothrow
{
    MObject result = null;
    if (id >= 0)
    {
        if (id < _world.length)
        {
            result = _world[id];
        }
        if (result is null && shouldCreate)
        {
            expandDatabase(id + 1);
            result = _world[id] = new MObject(id);
        }
    }
    return result;
}


/**
 *  Perform a cycle of pending work.
 */
@safe void runDatabase() nothrow
{
}


/**
 *  Database startup.
 */
@safe void startDatabase()
{
    exitCodeEnforce!`Internal`(!_active, "start() called on an already active database");
    log("Starting database.");
    loadDatabase();
    exitCodeEnforce!`InvalidDb`(validateDatabase(), "database failed validation");
    _active = true;
}


/**
 *  Database shutdown.
 */
@safe void stopDatabase()
{
    if (_active)
    {
        log("Stopping database");
        dumpDatabase(true);
        destroy(_world);
        _active = false;
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////////
package:


/**
 *
 */
@trusted void dumpDatabase(bool finalize = false)
{
    import  std.conv;

    import  dumper = moo.db.dump;

    string path = config.dbPath;
    if (finalize)
    {
        path ~= ".final";
    }
    else
    {
        path ~= text('.', ++_dumpCounter);
    }
    try
    {
        auto file = File(path, `wb`);
        dumper.dump(file);
    }
    catch (ExitCodeException xcx)
    {
        throw xcx;
    }
    catch (Exception x)
    {
        throw new ExitCodeException(ExitCode.Generic, "Failed dumping database", x);
    }
}


/**
 *  Expand the database, as necessary, out to a minimum size.
 *
 *  Params:
 *      requestedSize = the desired minimum size (kinda obvious)
 */
@safe void expandDatabase(in size_t requestedSize) nothrow
{
    if (_world.length < requestedSize)
    {
        _world.length = requestedSize;
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////////
private:


/**
 *  Load the database from its file.
 */
@trusted void loadDatabase()
{
    import  std.file    : exists    ;
    import  std.stdio   : File      ;

    import  lloader = moo.db.load_lambda;
    import  rloader = moo.db.load_remoo;

    exitCodeEnforce!`FileNotFound`(config.dbPath.exists(), "Did not find database file " ~ config.dbPath);
    try
    {
        auto file = File(config.dbPath, `r`);
        if (config.lambda)
        {
            lloader.load(file);
            config.changeDBPathExtension();
        }
        else
        {
            rloader.load(file);
        }
    }
    catch (ExitCodeException xcx)
    {
        throw xcx;
    }
    catch (Exception x)
    {
        throw new ExitCodeException(ExitCode.Generic, "Failed loading database", x);
    }
}


/**
 *  Validate a loaded database, checking for inheritance/location cycles, invalid owners, etc.
 *
 *  Returns: true for pass, false for fail.
 */
@safe bool validateDatabase () pure nothrow
{
    bool pass = true;
    return pass;
}

