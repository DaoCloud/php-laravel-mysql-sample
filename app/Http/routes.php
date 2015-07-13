<?php

/*
|--------------------------------------------------------------------------
| Application Routes
|--------------------------------------------------------------------------
|
| Here is where you can register all of the routes for an application.
| It's a breeze. Simply tell Laravel the URIs it should respond to
| and give it the controller to call when that URI is requested.
|
*/

use App\Contact;

Route::get('/', function () {
    try {
        $contacts = Contact::all();

    } catch (PDOException $e) {
        try {
            Artisan::call('migrate');
            Artisan::call('db:seed');
        } catch (PDOException $e) {
            return '请确认数据库链接是否正确';
        }
        return '数据库创建中，请刷新';
    }

    return view('contacts')
        ->with('contacts', $contacts);
});

Route::post('/', function () {
    Contact::create(Input::all());

    return back();
});

Route::get('/{id}/delete', function ($id) {
    $contact = Contact::find($id);

    $contact->delete();

    return back();
});