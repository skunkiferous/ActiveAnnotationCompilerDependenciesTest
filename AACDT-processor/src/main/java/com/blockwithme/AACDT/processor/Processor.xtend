/*
 * Copyright (C) 2014 Sebastien Diot.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.blockwithme.AACDT.processor

import java.lang.annotation.ElementType
import java.lang.annotation.Retention
import java.lang.annotation.RetentionPolicy
import java.lang.annotation.Target
import java.util.List
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.TransformationParticipant
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility

class SomeBaseClass {

}

interface IDProvider {
	def int idOf(String qualifiedName)
}

@Active(typeof(Processor))
@Target(ElementType.TYPE)
@Retention(RetentionPolicy.CLASS)
annotation MyIDProvider {
	String value
}

/**
 * Tries to Process an annotated type, but fails because it does not have access
 * to the dependencies to the project where the annotated type lies.
 *
 * @author monster
 */
class Processor
      implements TransformationParticipant<MutableClassDeclaration> {

  override doTransform(List<? extends MutableClassDeclaration> classes,
                       extension TransformationContext context) {
   	for (annotatedClass : classes) {
   		val annotatedClassQualifiedName = annotatedClass.qualifiedName
   		val classAnnotation = annotatedClass.findAnnotation(context.findTypeGlobally(MyIDProvider))
   		val providerQualifiedName = classAnnotation.getStringValue("value")
   		val idProvider = Class.forName(providerQualifiedName).newInstance as IDProvider
   		val id = idProvider.idOf(annotatedClassQualifiedName)
   		annotatedClass.addField("ID", [f|
   			f.visibility = Visibility.PUBLIC
   			f.static = true
   			f.final = true
   			f.initializer = '''«id»'''
   		])
   	}
  }
}
