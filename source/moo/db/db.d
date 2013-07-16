/*//////////////////////////////////////////////////////////////////////////////////////////////////
////                                                                                            ////
////    Copyright 2013 Christopher Nicholson-Sauls                                              ////
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
 *
 */
module moo.db.db;


/**
 *
 */
final class Database
{
    import moo.log;
    import moo.patterns.singleton;

    mixin Singleton;


    private {
        Logger _log;
    }


    /**
     *
     */
    void start ( string  path ) {
        import moo.exception;

        _log = Logger( `database` );
        load( path );
        exitCodeEnforce!`INVALID_DB`( validate(), `Database in ` ~ path ~ ` fails validation.`);
    }


    /**
     *
     */
    void stop () {}


    //==========================================================================================
    private:


    /**
     *
     */
    void load ( string path ) {
        _log( `Loading database from %s`, path );
    }


    /**
     *
     */
    bool validate () { return false; } //TODO


} // end Database

