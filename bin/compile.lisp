(in-package :cl-user)

(require :asdf)

(defvar *build-dir* (pathname-directory (pathname (concatenate 'string (asdf::getenv "BUILD_DIR") "/"))))
(defvar *build-dir2* (truename (concatenate 'string (asdf::getenv "BUILD_DIR") "/")))
(defvar *cache-dir* (pathname-directory (pathname (concatenate 'string (asdf::getenv "CACHE_DIR") "/"))))
(defvar *buildpack-dir* (pathname-directory (pathname (concatenate 'string (asdf::getenv "BUILDPACK_DIR") "/"))))

(defparameter *fasl-dir* (merge-pathnames "fasl/" *build-dir2*))
(format t "*build-dir*: ~A~%" *build-dir*)
(format t "*fasl-dir*: ~A~%" *fasl-dir*)

(format t "XDG_CACHE_HOME: ~A~%" (asdf:getenv "XDG_CACHE_HOME"))

(load (make-pathname :directory *build-dir* :defaults "buildpack-utils.lisp"))

(add-asdf-output-translation *build-dir2* *fasl-dir*)

(let ((ql-setup (make-pathname :directory (append *build-dir* '("quicklisp")) :defaults "setup.lisp")))
  (format t "ql-setup: ~A~%" ql-setup)
  (if (probe-file ql-setup)
      (load ql-setup)
      (progn
	(load (make-pathname :directory (append *buildpack-dir* '("lib")) :defaults "quicklisp.lisp"))
	(funcall (read-from-string "quicklisp-quickstart:install")
		 :path (make-pathname :directory (pathname-directory ql-setup))))))

;;; Load the application from sources
(load (make-pathname :directory *build-dir* :defaults "heroku-setup.lisp"))
(heroku-compile)
