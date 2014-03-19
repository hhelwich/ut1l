ut1l [![.](https://badge.fury.io/js/ut1l.png)](http://badge.fury.io/js/ut1l) [![.](https://travis-ci.org/hhelwich/ut1l.png?branch=master)](https://travis-ci.org/hhelwich/ut1l) [![.](https://coveralls.io/repos/hhelwich/ut1l/badge.png?branch=master)](https://coveralls.io/r/hhelwich/ut1l?branch=master)
====

A small utility library for JavaScript.

Usage
-----

### Browser

To use the library in the browser, you need to include [this](https://raw.github.com/hhelwich/ut1l/master/dist/ut1l.min.js) JavaScript file:

```html
<script src="ut1l.min.js"></script>
```

It exports the global `ut1l` object. 
You can create alias variables (used by the examples below):

```javascript
var O = ut1l.create.object,
    T = ut1l.create.throwable;
```

The following browsers are tested:

[![Browser Test Status](https://saucelabs.com/browser-matrix/ut1l.svg)](https://saucelabs.com/u/ut1l)


### Node.js

Install this package with:

```
npm install ut1l
```

You can create alias variables (used by the examples below):

```javascript
var O = require("ut1l/create/object"),
    T = require("ut1l/create/throwable");
```


Examples
--------


### Object creation

If you are not a big fan of classical inheritance in JavaScript and want to create multiple similar objects you can do e.g. like this:

```javascript
var person, bill;

person = function (firstName, lastName) {
    return {
        firstName: firstName,
        lastName: lastName
    }
};

bill = person('Bill', 'Gates');

console.log(bill.firstName); // Bill
```

But sometimes you want to know if an object is of some given “type”. This can be done with `instanceof` which is supported by this lib:

```javascript
person = O(function (firstName, lastName) { // constructor function
    this.firstName = firstName;
    this.lastName = lastName;
});

bill = person('Bill', 'Gates');

console.log(bill.firstName); // Bill
console.log(bill instanceof person); // true
```

You can also specify an object which should be used as prototype:


```javascript
person = O(function (firstName, lastName) { // constructor function
    this.firstName = firstName;
    this.lastName = lastName;
}, { // prototype
    getName: function() {
        return this.firstName + ' ' + this.lastName;
    }
});

bill = person('Bill', 'Gates');

console.log(bill.firstName); // Bill
console.log(bill instanceof person); // true

console.log(bill.getName()); // Bill Gates
```

An additional object can be passed as first parameter which fields will be available in the returned constructor:


```javascript
person = O({ // static fields
    isPerson: function(obj) {
        return obj instanceof this;
    }
}, function (firstName, lastName) { // constructor function
    this.firstName = firstName;
    this.lastName = lastName;
}, { // prototype
    getName: function() {
        return this.firstName + ' ' + this.lastName;
    }
});

bill = person('Bill', 'Gates');

console.log(bill.firstName); // Bill
console.log(bill instanceof person); // true
console.log(bill.getName()); // Bill Gates

console.log(person.isPerson(bill)); // true
```


### Throwables

You can create and use throwables like this:

```javascript
var myThrowable = T('MyThrowable'), // top level throwable constructor
    mySubThrowable = T('MySubThrowable', myThrowable); // sub throwable constructor
    
// ...
if (somethingBadHappened) {
    throw myThrowable('Something bad happened!');
}
```

It is easy to build a type tree of throwables if needed. They work with `instanceof` and the thrown objects have a stack property if this is supported by the interpreter.

Additionally to `try...catch` throwables can be caught like this:

```javascript
actionProxy = T.c4tch(throwable1, throwable2, ..., action, onError); 
```

The action function is proxied and all given throwable types (and their sub types) are caught for this action. If no throwable type is given, all throwables are caught.

A combined example:


```javascript
var notANumber, divide;

// create new throwable type
notANumber = T('NotANumber');

// create division function which throws on division by zero
divide = function (a, b) {
    if (b === 0) {
        throw notANumber('Division by zero');
    }
    return a / b;
};

// proxy division function which handles all NotANumber errors
divide = T.c4tch(notANumber, divide, function () {
   return 42;
});

console.log(divide(1, 2)); // 0.5
console.log(divide(5, 0)); // 42
```
